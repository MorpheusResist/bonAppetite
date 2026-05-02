import Foundation
import SwiftData

@MainActor
final class KitchenStore: ObservableObject {
    @Published var inventory: [PantryItem]
    @Published var recipes: [Recipe]
    @Published var shoppingItems: [ShoppingItem]
    @Published var analytics: [AnalyticsEntry]
    @Published var preferences: UserPreferences
    @Published var onboardingCompleted: Bool
    @Published var selectedScanMode: ScanMode = .fridge
    @Published var detectedIngredients: [DetectedIngredient] = []
    @Published var isScanning = false
    @Published var scanError: String?
    @Published var lastNotificationPreview: NotificationPreview?

    private let detectionService: IngredientDetectionService
    private let recipeService: RecipeGenerationService
    private let nutritionEstimator: NutritionEstimating
    private let shoppingEngine = ShoppingListEngine()
    private let riskEngine = ExpiryRiskEngine()
    private let notificationScheduler = NotificationScheduler()
    private var modelContext: ModelContext?
    private var hasConfiguredContext = false

    init(
        detectionService: IngredientDetectionService = MockIngredientDetectionService(),
        recipeService: RecipeGenerationService = LocalRecipeGenerationService(),
        nutritionEstimator: NutritionEstimating = NutritionEstimator()
    ) {
        self.detectionService = detectionService
        self.recipeService = recipeService
        self.nutritionEstimator = nutritionEstimator
        self.inventory = SampleData.pantryItems()
        self.recipes = SampleData.recipes()
        self.shoppingItems = SampleData.shoppingItems()
        self.analytics = SampleData.analyticsEntries()
        self.preferences = Self.loadPreferences()

        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-ui-testing") {
            self.onboardingCompleted = arguments.contains("-skip-onboarding")
        } else {
            self.onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        }
    }

    func configure(modelContext: ModelContext) {
        guard !hasConfiguredContext else { return }
        hasConfiguredContext = true
        self.modelContext = modelContext

        if ProcessInfo.processInfo.arguments.contains("-ui-testing-reset") {
            clearPersistedData()
        }

        do {
            let itemCount = try modelContext.fetchCount(FetchDescriptor<PantryItem>())
            if itemCount == 0 {
                seed(modelContext)
            }
            refreshFromStore()
        } catch {
            seed(modelContext)
            refreshFromStore()
        }
    }

    func completeOnboarding() {
        onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        savePreferences()
    }

    func resetOnboardingForDemo() {
        onboardingCompleted = false
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
    }

    func recipeMatches(useExpiringFirst: Bool = true) -> [RecipeMatch] {
        recipeService.generateMatches(
            inventory: inventory,
            recipes: recipes,
            preferences: preferences,
            useExpiringFirst: useExpiringFirst
        )
    }

    func topRecipeMatch() -> RecipeMatch? {
        recipeMatches().first
    }

    func expiringSoon() -> [PantryItem] {
        riskEngine.expiringSoon(from: inventory)
    }

    func risk(for item: PantryItem) -> FreshnessRisk {
        riskEngine.risk(for: item)
    }

    func badgeText(for item: PantryItem) -> String {
        riskEngine.badgeText(for: item)
    }

    func nutritionSummary() -> NutritionSummary {
        nutritionEstimator.estimate(items: inventory)
    }

    func scanSelectedImage(data: Data?) async {
        isScanning = true
        scanError = nil
        do {
            detectedIngredients = try await detectionService.detectIngredients(mode: selectedScanMode, imageData: data)
            Haptics.success()
        } catch {
            scanError = error.localizedDescription
            Haptics.warning()
        }
        isScanning = false
    }

    func addDetectedIngredients(_ detections: [DetectedIngredient]) {
        detections.map(ItemDraft.init(detected:)).forEach(addItem)
        detectedIngredients.removeAll()
    }

    func addItem(_ draft: ItemDraft) {
        let item = draft.makeItem()
        inventory.append(item)
        modelContext?.insert(item)
        saveContext()
        Haptics.light()
    }

    func updateItem(id: UUID, draft: ItemDraft) {
        guard let item = inventory.first(where: { $0.id == id }) else { return }
        item.name = draft.name
        item.category = draft.category
        item.location = draft.location
        item.quantity = draft.quantity
        item.unit = draft.unit
        item.expiryDate = draft.expiryDate
        item.priceEstimate = draft.priceEstimate
        item.caloriesPerUnit = draft.caloriesPerUnit
        item.proteinPerUnit = draft.proteinPerUnit
        item.confidence = draft.confidence
        item.notes = draft.notes
        saveContext()
        objectWillChange.send()
    }

    func consume(_ item: PantryItem) {
        item.status = .consumed
        analytics.append(AnalyticsEntry(date: .now, foodSavedCount: 1, wastedCount: 0, moneySaved: item.priceEstimate, category: item.category))
        modelContext?.insert(analytics.last!)
        saveContext()
        objectWillChange.send()
        Haptics.success()
    }

    func discard(_ item: PantryItem) {
        item.status = .discarded
        analytics.append(AnalyticsEntry(date: .now, foodSavedCount: 0, wastedCount: 1, moneySaved: 0, category: item.category))
        modelContext?.insert(analytics.last!)
        saveContext()
        objectWillChange.send()
        Haptics.warning()
    }

    func addMissingIngredientsToShopping(from match: RecipeMatch) {
        let newItems = shoppingEngine.makeShoppingItems(from: match)
        shoppingItems.append(contentsOf: newItems)
        newItems.forEach { modelContext?.insert($0) }
        shoppingItems = shoppingEngine.deduplicate(shoppingItems)
        saveContext()
        Haptics.success()
    }

    func toggleShoppingItem(_ item: ShoppingItem) {
        item.isChecked.toggle()
        saveContext()
        objectWillChange.send()
        Haptics.light()
    }

    func addShoppingItem(name: String, category: FoodCategory = .other) {
        let item = ShoppingItem(name: name, category: category, source: "Manual")
        shoppingItems.append(item)
        modelContext?.insert(item)
        saveContext()
    }

    func convertPurchasedToInventory() {
        let purchased = shoppingItems.filter { $0.isChecked }
        for shopping in purchased {
            let location = defaultLocation(for: shopping.category)
            let pantry = PantryItem(
                name: shopping.name,
                category: shopping.category,
                location: location,
                quantity: shopping.quantity,
                unit: shopping.unit,
                expiryDate: defaultExpiry(for: shopping.category),
                priceEstimate: 3.99,
                confidence: 0.92,
                notes: "Added from shopping list"
            )
            inventory.append(pantry)
            modelContext?.insert(pantry)
            if let context = modelContext {
                context.delete(shopping)
            }
        }
        shoppingItems.removeAll { $0.isChecked }
        saveContext()
        Haptics.success()
    }

    func markCooked(_ match: RecipeMatch) {
        let session = CookingSession(recipeTitle: match.recipe.title, completedAt: .now, consumedIngredients: match.matchedIngredients)
        modelContext?.insert(session)

        for ingredient in match.matchedIngredients {
            if let item = inventory.first(where: { item in
                item.status == .available && ingredientMatch(owned: item.name, requested: ingredient)
            }) {
                item.quantity = max(0, item.quantity - 1)
                if item.quantity == 0 {
                    item.status = .consumed
                }
            }
        }

        let saved = match.expiringIngredients.isEmpty ? 1 : match.expiringIngredients.count
        let money = match.matchedIngredients.reduce(0.0) { total, ingredient in
            total + (inventory.first { ingredientMatch(owned: $0.name, requested: ingredient) }?.priceEstimate ?? 1.5)
        }
        let entry = AnalyticsEntry(date: .now, foodSavedCount: saved, wastedCount: 0, moneySaved: min(money, 18), category: .produce)
        analytics.append(entry)
        modelContext?.insert(entry)
        saveContext()
        objectWillChange.send()
        Haptics.success()
    }

    func requestAndScheduleNotifications() async {
        let granted = await notificationScheduler.requestAuthorization()
        if granted {
            await notificationScheduler.scheduleExpiryReminder(for: inventory, preferences: preferences)
        }
        lastNotificationPreview = notificationScheduler.preview(for: inventory, preferences: preferences)
    }

    func notificationPreview() -> NotificationPreview? {
        notificationScheduler.preview(for: inventory, preferences: preferences)
    }

    func savePreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    func resetDemoData() {
        clearPersistedData()
        if let context = modelContext {
            seed(context)
            refreshFromStore()
        } else {
            inventory = SampleData.pantryItems()
            recipes = SampleData.recipes()
            shoppingItems = SampleData.shoppingItems()
            analytics = SampleData.analyticsEntries()
        }
        preferences = UserPreferences()
        savePreferences()
    }

    func exportSummary() -> String {
        let expiring = expiringSoon().map(\.name).joined(separator: ", ")
        let top = topRecipeMatch()?.recipe.title ?? "No recommendation"
        let saved = analytics.reduce(0) { $0 + $1.moneySaved }
        return """
        WasteLess Kitchen Export
        Inventory items: \(inventory.filter { $0.status == .available }.count)
        Expiring soon: \(expiring)
        Cook tonight: \(top)
        Estimated money saved: $\(String(format: "%.0f", saved))
        """
    }

    private func refreshFromStore() {
        guard let modelContext else { return }
        do {
            inventory = try modelContext.fetch(FetchDescriptor<PantryItem>()).sorted { $0.name < $1.name }
            recipes = try modelContext.fetch(FetchDescriptor<Recipe>()).sorted { $0.title < $1.title }
            shoppingItems = try modelContext.fetch(FetchDescriptor<ShoppingItem>()).sorted { $0.name < $1.name }
            analytics = try modelContext.fetch(FetchDescriptor<AnalyticsEntry>()).sorted { $0.date < $1.date }
        } catch {
            inventory = SampleData.pantryItems()
            recipes = SampleData.recipes()
            shoppingItems = SampleData.shoppingItems()
            analytics = SampleData.analyticsEntries()
        }
    }

    private func seed(_ context: ModelContext) {
        SampleData.pantryItems().forEach(context.insert)
        SampleData.recipes().forEach(context.insert)
        SampleData.shoppingItems().forEach(context.insert)
        SampleData.analyticsEntries().forEach(context.insert)
        saveContext()
    }

    private func clearPersistedData() {
        guard let modelContext else { return }
        try? modelContext.delete(model: PantryItem.self)
        try? modelContext.delete(model: Recipe.self)
        try? modelContext.delete(model: ShoppingItem.self)
        try? modelContext.delete(model: AnalyticsEntry.self)
        try? modelContext.delete(model: CookingSession.self)
        saveContext()
    }

    private func saveContext() {
        try? modelContext?.save()
    }

    private static func loadPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return preferences
    }

    private func defaultLocation(for category: FoodCategory) -> FoodLocation {
        switch category {
        case .produce, .dairy, .protein, .beverage: .fridge
        case .frozen: .freezer
        case .spices: .spices
        default: .pantry
        }
    }

    private func defaultExpiry(for category: FoodCategory) -> Date? {
        switch category {
        case .produce: Date.daysFromNow(5)
        case .dairy, .protein, .bakery: Date.daysFromNow(7)
        case .frozen: Date.daysFromNow(60)
        case .spices, .canned, .condiment, .grains: Date.daysFromNow(180)
        default: Date.daysFromNow(30)
        }
    }

    private func ingredientMatch(owned: String, requested: String) -> Bool {
        let owned = owned.lowercased()
        let requested = requested.lowercased()
        return owned == requested || owned.contains(requested) || requested.contains(owned)
    }
}
