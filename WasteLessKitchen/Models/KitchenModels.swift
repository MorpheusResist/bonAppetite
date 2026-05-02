import Foundation
import SwiftData

enum FoodLocation: String, CaseIterable, Codable, Identifiable {
    case fridge = "Fridge"
    case freezer = "Freezer"
    case pantry = "Pantry"
    case spices = "Spices"
    case shopping = "Shopping"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .fridge: "refrigerator"
        case .freezer: "snowflake"
        case .pantry: "cabinet"
        case .spices: "leaf"
        case .shopping: "cart"
        }
    }
}

enum FoodCategory: String, CaseIterable, Codable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy"
    case protein = "Protein"
    case grains = "Grains"
    case canned = "Canned"
    case frozen = "Frozen"
    case spices = "Spices"
    case bakery = "Bakery"
    case beverage = "Beverage"
    case snack = "Snack"
    case condiment = "Condiment"
    case other = "Other"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .produce: "carrot"
        case .dairy: "drop"
        case .protein: "fork.knife"
        case .grains: "takeoutbag.and.cup.and.straw"
        case .canned: "shippingbox"
        case .frozen: "snowflake.circle"
        case .spices: "sparkles"
        case .bakery: "birthday.cake"
        case .beverage: "cup.and.saucer"
        case .snack: "popcorn"
        case .condiment: "bottle"
        case .other: "square.grid.2x2"
        }
    }
}

enum FoodStatus: String, Codable, CaseIterable {
    case available = "Available"
    case consumed = "Consumed"
    case discarded = "Discarded"
}

enum FreshnessRisk: String, CaseIterable, Codable, Identifiable {
    case expired = "Expired"
    case today = "Use Today"
    case soon = "Soon"
    case fresh = "Fresh"
    case shelfStable = "Shelf Stable"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .expired: "xmark.octagon.fill"
        case .today: "exclamationmark.triangle.fill"
        case .soon: "clock.badge.exclamationmark"
        case .fresh: "checkmark.seal.fill"
        case .shelfStable: "archivebox.fill"
        }
    }
}

enum DietTag: String, CaseIterable, Codable, Identifiable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case highProtein = "High Protein"
    case keto = "Keto"
    case pescatarian = "Pescatarian"
    case lowCalorie = "Low Calorie"

    var id: String { rawValue }
}

enum CookingSkill: String, CaseIterable, Codable, Identifiable {
    case beginner = "Beginner"
    case confident = "Confident"
    case adventurous = "Adventurous"

    var id: String { rawValue }
}

enum BudgetLevel: String, CaseIterable, Codable, Identifiable {
    case saver = "Saver"
    case balanced = "Balanced"
    case flexible = "Flexible"

    var id: String { rawValue }
}

enum NotificationStyle: String, CaseIterable, Codable, Identifiable {
    case quiet = "Quiet"
    case dailyDigest = "Daily Digest"
    case urgentOnly = "Urgent Only"

    var id: String { rawValue }
}

enum ScanMode: String, CaseIterable, Codable, Identifiable {
    case fridge = "Fridge"
    case pantry = "Pantry"
    case freezer = "Freezer"
    case receipt = "Receipt"
    case barcode = "Barcode"
    case label = "Label"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .fridge: "refrigerator"
        case .pantry: "cabinet"
        case .freezer: "snowflake"
        case .receipt: "receipt"
        case .barcode: "barcode.viewfinder"
        case .label: "tag"
        }
    }
}

struct UserPreferences: Codable, Equatable {
    var householdSize: Int = 2
    var selectedDiets: Set<DietTag> = [.highProtein]
    var allergies: Set<String> = ["Peanuts"]
    var cookingSkill: CookingSkill = .confident
    var budget: BudgetLevel = .balanced
    var notificationStyle: NotificationStyle = .dailyDigest
    var preferredCuisines: Set<String> = ["Mediterranean", "Japanese", "Mexican"]
    var prefersHighContrast: Bool = false
    var prefersLargeCookingText: Bool = true
    var prefersDyslexiaFont: Bool = false
    var reduceMotionInApp: Bool = false
    var dailyProteinGoal: Int = 95
    var dailyCalorieGoal: Int = 2100
}

@Model
final class PantryItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var locationRaw: String
    var quantity: Double
    var unit: String
    var expiryDate: Date?
    var purchaseDate: Date
    var priceEstimate: Double
    var caloriesPerUnit: Int
    var proteinPerUnit: Double
    var confidence: Double
    var statusRaw: String
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        category: FoodCategory,
        location: FoodLocation,
        quantity: Double,
        unit: String,
        expiryDate: Date?,
        purchaseDate: Date = .now,
        priceEstimate: Double = 3.99,
        caloriesPerUnit: Int = 120,
        proteinPerUnit: Double = 3,
        confidence: Double = 1,
        status: FoodStatus = .available,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.locationRaw = location.rawValue
        self.quantity = quantity
        self.unit = unit
        self.expiryDate = expiryDate
        self.purchaseDate = purchaseDate
        self.priceEstimate = priceEstimate
        self.caloriesPerUnit = caloriesPerUnit
        self.proteinPerUnit = proteinPerUnit
        self.confidence = confidence
        self.statusRaw = status.rawValue
        self.notes = notes
    }

    var category: FoodCategory {
        get { FoodCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var location: FoodLocation {
        get { FoodLocation(rawValue: locationRaw) ?? .pantry }
        set { locationRaw = newValue.rawValue }
    }

    var status: FoodStatus {
        get { FoodStatus(rawValue: statusRaw) ?? .available }
        set { statusRaw = newValue.rawValue }
    }

    var normalizedName: String {
        name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@Model
final class Recipe: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String
    var cuisine: String
    var dietTagsRaw: [String]
    var allergyWarnings: [String]
    var ingredients: [String]
    var steps: [String]
    var stepMinutes: [Int]
    var equipment: [String]
    var cookTimeMinutes: Int
    var calories: Int
    var protein: Int
    var estimatedCost: Double
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        cuisine: String,
        dietTags: [DietTag],
        allergyWarnings: [String] = [],
        ingredients: [String],
        steps: [String],
        stepMinutes: [Int],
        equipment: [String],
        cookTimeMinutes: Int,
        calories: Int,
        protein: Int,
        estimatedCost: Double,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.cuisine = cuisine
        self.dietTagsRaw = dietTags.map(\.rawValue)
        self.allergyWarnings = allergyWarnings
        self.ingredients = ingredients
        self.steps = steps
        self.stepMinutes = stepMinutes
        self.equipment = equipment
        self.cookTimeMinutes = cookTimeMinutes
        self.calories = calories
        self.protein = protein
        self.estimatedCost = estimatedCost
        self.isFavorite = isFavorite
    }

    var dietTags: [DietTag] {
        get { dietTagsRaw.compactMap(DietTag.init(rawValue:)) }
        set { dietTagsRaw = newValue.map(\.rawValue) }
    }

    var cookingSteps: [CookingStep] {
        steps.enumerated().map { index, text in
            CookingStep(
                order: index + 1,
                instruction: text,
                minutes: stepMinutes.indices.contains(index) ? stepMinutes[index] : 0
            )
        }
    }
}

@Model
final class ShoppingItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var quantity: Double
    var unit: String
    var source: String
    var isChecked: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: FoodCategory,
        quantity: Double = 1,
        unit: String = "item",
        source: String = "Manual",
        isChecked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.quantity = quantity
        self.unit = unit
        self.source = source
        self.isChecked = isChecked
    }

    var category: FoodCategory {
        get { FoodCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}

@Model
final class AnalyticsEntry: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var foodSavedCount: Int
    var wastedCount: Int
    var moneySaved: Double
    var categoryRaw: String

    init(
        id: UUID = UUID(),
        date: Date,
        foodSavedCount: Int,
        wastedCount: Int,
        moneySaved: Double,
        category: FoodCategory
    ) {
        self.id = id
        self.date = date
        self.foodSavedCount = foodSavedCount
        self.wastedCount = wastedCount
        self.moneySaved = moneySaved
        self.categoryRaw = category.rawValue
    }

    var category: FoodCategory {
        get { FoodCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}

@Model
final class CookingSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var recipeTitle: String
    var startedAt: Date
    var completedAt: Date?
    var consumedIngredients: [String]

    init(
        id: UUID = UUID(),
        recipeTitle: String,
        startedAt: Date = .now,
        completedAt: Date? = nil,
        consumedIngredients: [String] = []
    ) {
        self.id = id
        self.recipeTitle = recipeTitle
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.consumedIngredients = consumedIngredients
    }
}

struct CookingStep: Identifiable, Hashable {
    var id: Int { order }
    let order: Int
    let instruction: String
    let minutes: Int
}

struct DetectedIngredient: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var category: FoodCategory
    var location: FoodLocation
    var quantity: Double
    var unit: String
    var suggestedExpiry: Date?
    var confidence: Double
    var sourceHint: String
}

struct RecipeMatch: Identifiable {
    var id: UUID { recipe.id }
    let recipe: Recipe
    let score: Double
    let matchedIngredients: [String]
    let missingIngredients: [String]
    let expiringIngredients: [String]
    let explanation: String

    var matchPercentage: Int {
        Int((score * 100).rounded())
    }
}

struct NutritionSummary: Equatable {
    var calories: Int
    var protein: Int
    var produceServings: Int
    var highRiskItems: Int
}

struct NotificationPreview: Equatable {
    let title: String
    let body: String
    let itemNames: [String]
    let hour: Int
}

struct ItemDraft: Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var category: FoodCategory = .produce
    var location: FoodLocation = .fridge
    var quantity: Double = 1
    var unit: String = "item"
    var expiryDate: Date? = Calendar.current.date(byAdding: .day, value: 5, to: .now)
    var priceEstimate: Double = 3.99
    var caloriesPerUnit: Int = 120
    var proteinPerUnit: Double = 3
    var confidence: Double = 1
    var notes: String = ""

    init() {}

    init(detected: DetectedIngredient) {
        self.name = detected.name
        self.category = detected.category
        self.location = detected.location
        self.quantity = detected.quantity
        self.unit = detected.unit
        self.expiryDate = detected.suggestedExpiry
        self.confidence = detected.confidence
        self.notes = detected.sourceHint
    }

    init(item: PantryItem) {
        self.id = item.id
        self.name = item.name
        self.category = item.category
        self.location = item.location
        self.quantity = item.quantity
        self.unit = item.unit
        self.expiryDate = item.expiryDate
        self.priceEstimate = item.priceEstimate
        self.caloriesPerUnit = item.caloriesPerUnit
        self.proteinPerUnit = item.proteinPerUnit
        self.confidence = item.confidence
        self.notes = item.notes
    }

    func makeItem() -> PantryItem {
        PantryItem(
            name: name.isEmpty ? "New Item" : name,
            category: category,
            location: location,
            quantity: quantity,
            unit: unit,
            expiryDate: expiryDate,
            priceEstimate: priceEstimate,
            caloriesPerUnit: caloriesPerUnit,
            proteinPerUnit: proteinPerUnit,
            confidence: confidence,
            notes: notes
        )
    }
}

extension Date {
    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    var shortKitchenDate: String {
        formatted(.dateTime.month(.abbreviated).day())
    }
}
