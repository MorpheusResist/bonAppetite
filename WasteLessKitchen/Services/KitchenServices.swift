import AVFoundation
import Foundation
import UIKit
import UserNotifications

protocol IngredientDetectionService {
    func detectIngredients(mode: ScanMode, imageData: Data?) async throws -> [DetectedIngredient]
}

protocol RecipeGenerationService {
    func generateMatches(inventory: [PantryItem], recipes: [Recipe], preferences: UserPreferences, useExpiringFirst: Bool) -> [RecipeMatch]
}

protocol NutritionEstimating {
    func estimate(items: [PantryItem]) -> NutritionSummary
}

protocol ShoppingListBuilding {
    func makeShoppingItems(from match: RecipeMatch) -> [ShoppingItem]
}

enum DetectionError: Error, LocalizedError {
    case noUsableImage

    var errorDescription: String? {
        "WasteLess Kitchen could not read that image. Try a brighter photo or add the items manually."
    }
}

struct MockIngredientDetectionService: IngredientDetectionService {
    func detectIngredients(mode: ScanMode, imageData: Data?) async throws -> [DetectedIngredient] {
        try await Task.sleep(nanoseconds: 550_000_000)
        let jitter = Double((imageData?.count ?? 8_421) % 9) / 100

        func expiry(_ days: Int) -> Date { Date.daysFromNow(days) }

        let items: [DetectedIngredient]
        switch mode {
        case .fridge:
            items = [
                detected("Baby Spinach", .produce, .fridge, 1, "bag", expiry(1), 0.93 + jitter, "leafy greens in crisper"),
                detected("Greek Yogurt", .dairy, .fridge, 2, "cups", expiry(5), 0.89, "white tub label"),
                detected("Avocados", .produce, .fridge, 3, "each", expiry(0), 0.86, "ripe dark skins"),
                detected("Mushrooms", .produce, .fridge, 1, "box", expiry(2), 0.91, "clear produce box")
            ]
        case .pantry:
            items = [
                detected("Canned Chickpeas", .canned, .pantry, 2, "cans", expiry(365), 0.96, "stacked cans"),
                detected("Brown Rice", .grains, .pantry, 1, "bag", expiry(120), 0.88, "grain pouch"),
                detected("Peanut Butter", .condiment, .pantry, 1, "jar", expiry(90), 0.92, "jar barcode text"),
                detected("Tortillas", .bakery, .pantry, 6, "wraps", expiry(6), 0.84, "plastic package")
            ]
        case .freezer:
            items = [
                detected("Salmon Fillets", .protein, .freezer, 2, "fillets", expiry(30), 0.88, "vacuum bag"),
                detected("Frozen Peas", .frozen, .freezer, 1, "bag", expiry(90), 0.95, "green bag"),
                detected("Frozen Berries", .frozen, .freezer, 1, "bag", expiry(75), 0.91, "berry image on pouch")
            ]
        case .receipt:
            items = [
                detected("Whole Milk", .dairy, .fridge, 1, "gallon", expiry(7), 0.82, "receipt line: MILK WHL"),
                detected("Eggs", .protein, .fridge, 12, "eggs", expiry(18), 0.87, "receipt line: EGGS LG"),
                detected("Bell Peppers", .produce, .fridge, 4, "each", expiry(5), 0.8, "produce receipt abbreviation"),
                detected("Cilantro", .produce, .fridge, 1, "bunch", expiry(3), 0.78, "receipt line: CILAN")
            ]
        case .barcode:
            items = [
                detected("Oat Milk", .beverage, .fridge, 1, "carton", expiry(14), 0.97, "barcode matched packaged beverage"),
                detected("Black Beans", .canned, .pantry, 1, "can", expiry(420), 0.94, "UPC product match")
            ]
        case .label:
            items = [
                detected("High Protein Granola", .snack, .pantry, 1, "bag", expiry(150), 0.84, "front label and nutrition panel"),
                detected("Coconut Milk", .canned, .pantry, 1, "can", expiry(220), 0.9, "ingredient label")
            ]
        }

        return items
    }

    private func detected(_ name: String, _ category: FoodCategory, _ location: FoodLocation, _ quantity: Double, _ unit: String, _ expiry: Date?, _ confidence: Double, _ source: String) -> DetectedIngredient {
        DetectedIngredient(
            name: name,
            category: category,
            location: location,
            quantity: quantity,
            unit: unit,
            suggestedExpiry: expiry,
            confidence: min(confidence, 0.99),
            sourceHint: source
        )
    }
}

struct ExpiryRiskEngine {
    var soonThresholdDays = 3

    func daysUntilExpiry(for item: PantryItem, now: Date = .now) -> Int? {
        guard let expiryDate = item.expiryDate else { return nil }
        let start = Calendar.current.startOfDay(for: now)
        let end = Calendar.current.startOfDay(for: expiryDate)
        return Calendar.current.dateComponents([.day], from: start, to: end).day
    }

    func risk(for item: PantryItem, now: Date = .now) -> FreshnessRisk {
        guard let days = daysUntilExpiry(for: item, now: now) else {
            return .shelfStable
        }
        if days < 0 { return .expired }
        if days == 0 { return .today }
        if days <= soonThresholdDays { return .soon }
        return .fresh
    }

    func expiringSoon(from items: [PantryItem], now: Date = .now) -> [PantryItem] {
        items
            .filter { $0.status == .available }
            .filter { [.expired, .today, .soon].contains(risk(for: $0, now: now)) }
            .sorted {
                (daysUntilExpiry(for: $0, now: now) ?? Int.max) < (daysUntilExpiry(for: $1, now: now) ?? Int.max)
            }
    }

    func badgeText(for item: PantryItem, now: Date = .now) -> String {
        switch risk(for: item, now: now) {
        case .expired: "Expired"
        case .today: "Today"
        case .soon:
            if let days = daysUntilExpiry(for: item, now: now) {
                "\(days)d"
            } else {
                "Soon"
            }
        case .fresh:
            if let days = daysUntilExpiry(for: item, now: now) {
                "\(days)d"
            } else {
                "Fresh"
            }
        case .shelfStable: "Stable"
        }
    }
}

struct LocalRecipeGenerationService: RecipeGenerationService {
    private let riskEngine = ExpiryRiskEngine()

    func generateMatches(inventory: [PantryItem], recipes: [Recipe], preferences: UserPreferences, useExpiringFirst: Bool = true) -> [RecipeMatch] {
        let availableItems = inventory.filter { $0.status == .available }
        let inventoryNames = availableItems.map(\.normalizedName)
        let expiringNames = Set(riskEngine.expiringSoon(from: availableItems).map { normalize($0.name) })

        return recipes.map { recipe in
            let matched = recipe.ingredients.filter { ingredient in
                inventoryNames.contains { owned in ingredientMatches(owned: owned, requested: normalize(ingredient)) }
            }
            let missing = recipe.ingredients.filter { ingredient in
                !matched.contains(where: { normalize($0) == normalize(ingredient) })
            }
            let expiring = recipe.ingredients.filter { expiringNames.contains(normalize($0)) }

            var score = Double(matched.count) / Double(max(recipe.ingredients.count, 1))
            if useExpiringFirst {
                score += min(Double(expiring.count) * 0.08, 0.22)
            }
            if !Set(recipe.dietTags).isDisjoint(with: preferences.selectedDiets) {
                score += 0.05
            }
            if preferences.preferredCuisines.contains(recipe.cuisine) {
                score += 0.04
            }
            if recipe.allergyWarnings.contains(where: { preferences.allergies.contains($0) }) {
                score -= 0.45
            }
            if preferences.budget == .saver, recipe.estimatedCost > 8 {
                score -= 0.08
            }
            if preferences.cookingSkill == .beginner, recipe.cookTimeMinutes > 25 {
                score -= 0.06
            }

            let boundedScore = min(max(score, 0), 1)
            let explanation = explanation(recipe: recipe, matched: matched, missing: missing, expiring: expiring)

            return RecipeMatch(
                recipe: recipe,
                score: boundedScore,
                matchedIngredients: matched,
                missingIngredients: missing,
                expiringIngredients: expiring,
                explanation: explanation
            )
        }
        .sorted {
            if abs($0.score - $1.score) > 0.001 {
                return $0.score > $1.score
            }
            return $0.recipe.cookTimeMinutes < $1.recipe.cookTimeMinutes
        }
    }

    private func ingredientMatches(owned: String, requested: String) -> Bool {
        let owned = normalize(owned)
        let requested = normalize(requested)
        return owned == requested || owned.contains(requested) || requested.contains(owned.dropLast(owned.hasSuffix("s") ? 1 : 0))
    }

    private func explanation(recipe: Recipe, matched: [String], missing: [String], expiring: [String]) -> String {
        if !expiring.isEmpty {
            return "Recommended because it uses \(expiring.joined(separator: ", ")) before it expires and you already have \(matched.count) of \(recipe.ingredients.count) ingredients."
        }
        if missing.isEmpty {
            return "You have everything needed, and it is a \(recipe.cookTimeMinutes)-minute meal."
        }
        return "You have \(matched.count) ingredients on hand. Add \(missing.prefix(2).joined(separator: " and ")) to make it tonight."
    }

    private func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct NutritionEstimator: NutritionEstimating {
    private let riskEngine = ExpiryRiskEngine()

    func estimate(items: [PantryItem]) -> NutritionSummary {
        let available = items.filter { $0.status == .available }
        return NutritionSummary(
            calories: available.reduce(0) { $0 + Int(Double($1.caloriesPerUnit) * max($1.quantity, 0)) },
            protein: Int(available.reduce(0) { $0 + $1.proteinPerUnit * max($1.quantity, 0) }),
            produceServings: Int(available.filter { $0.category == .produce }.reduce(0) { $0 + $1.quantity }),
            highRiskItems: available.filter { [.expired, .today, .soon].contains(riskEngine.risk(for: $0)) }.count
        )
    }
}

struct ShoppingListEngine: ShoppingListBuilding {
    func makeShoppingItems(from match: RecipeMatch) -> [ShoppingItem] {
        match.missingIngredients.map { ingredient in
            ShoppingItem(
                name: ingredient,
                category: inferredCategory(for: ingredient),
                quantity: 1,
                unit: "item",
                source: match.recipe.title
            )
        }
    }

    func deduplicate(_ items: [ShoppingItem]) -> [ShoppingItem] {
        var grouped: [String: ShoppingItem] = [:]
        for item in items {
            let key = item.name.lowercased()
            if let existing = grouped[key] {
                existing.quantity += item.quantity
                existing.source = [existing.source, item.source].filter { !$0.isEmpty }.joined(separator: ", ")
            } else {
                grouped[key] = item
            }
        }
        return grouped.values.sorted { $0.category.rawValue < $1.category.rawValue }
    }

    private func inferredCategory(for ingredient: String) -> FoodCategory {
        let value = ingredient.lowercased()
        if ["chicken", "salmon", "tofu", "egg"].contains(where: { value.contains($0) }) { return .protein }
        if ["milk", "yogurt", "cheddar", "mozzarella"].contains(where: { value.contains($0) }) { return .dairy }
        if ["rice", "pasta", "oat", "tortilla", "bread", "quinoa"].contains(where: { value.contains($0) }) { return .grains }
        if ["cumin", "paprika", "turmeric"].contains(where: { value.contains($0) }) { return .spices }
        if ["bean", "tomato", "coconut", "chickpea"].contains(where: { value.contains($0) }) { return .canned }
        if ["soy", "miso", "tahini", "oil", "butter"].contains(where: { value.contains($0) }) { return .condiment }
        return .produce
    }
}

struct NotificationScheduler {
    private let riskEngine = ExpiryRiskEngine()

    func preview(for items: [PantryItem], preferences: UserPreferences) -> NotificationPreview? {
        let candidates = riskEngine.expiringSoon(from: items).prefix(4).map(\.name)
        guard !candidates.isEmpty else { return nil }
        let title = preferences.notificationStyle == .urgentOnly ? "Use today" : "WasteLess Kitchen"
        let body = "Use \(candidates.joined(separator: ", ")) before it expires."
        return NotificationPreview(title: title, body: body, itemNames: Array(candidates), hour: 18)
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleExpiryReminder(for items: [PantryItem], preferences: UserPreferences) async {
        guard let preview = preview(for: items, preferences: preferences) else { return }
        let content = UNMutableNotificationContent()
        content.title = preview.title
        content.body = preview.body
        content.sound = .default

        var date = DateComponents()
        date.hour = preview.hour
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-expiry-reminder", content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}

@MainActor
final class SpeechCookingReader: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.46
        utterance.pitchMultiplier = 1.02
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}

enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
