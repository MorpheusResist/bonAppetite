import XCTest
@testable import WasteLessKitchen

@MainActor
final class WasteLessKitchenTests: XCTestCase {
    func testExpiryRiskSortingPutsExpiredAndTodayFirst() {
        let engine = ExpiryRiskEngine()
        let items = [
            PantryItem(name: "Later", category: .produce, location: .fridge, quantity: 1, unit: "item", expiryDate: Date.daysFromNow(5)),
            PantryItem(name: "Expired", category: .produce, location: .fridge, quantity: 1, unit: "item", expiryDate: Date.daysFromNow(-1)),
            PantryItem(name: "Today", category: .produce, location: .fridge, quantity: 1, unit: "item", expiryDate: Date.daysFromNow(0))
        ]

        let sorted = engine.expiringSoon(from: items)

        XCTAssertEqual(sorted.map(\.name), ["Expired", "Today"])
        XCTAssertEqual(engine.risk(for: sorted[0]), .expired)
        XCTAssertEqual(engine.risk(for: sorted[1]), .today)
    }

    func testRecipeMatchScoringPrioritizesExpiringIngredients() {
        let service = LocalRecipeGenerationService()
        let inventory = [
            PantryItem(name: "Avocados", category: .produce, location: .fridge, quantity: 2, unit: "each", expiryDate: Date.daysFromNow(0)),
            PantryItem(name: "Canned Chickpeas", category: .canned, location: .pantry, quantity: 1, unit: "can", expiryDate: Date.daysFromNow(200)),
            PantryItem(name: "Sourdough Bread", category: .bakery, location: .pantry, quantity: 1, unit: "loaf", expiryDate: Date.daysFromNow(2)),
            PantryItem(name: "Lemons", category: .produce, location: .fridge, quantity: 1, unit: "each", expiryDate: Date.daysFromNow(8))
        ]

        let matches = service.generateMatches(
            inventory: inventory,
            recipes: SampleData.recipes(),
            preferences: UserPreferences(),
            useExpiringFirst: true
        )

        XCTAssertEqual(matches.first?.recipe.title, "Avocado Chickpea Toast")
        XCTAssertTrue(matches.first?.expiringIngredients.contains("Avocados") == true)
    }

    func testShoppingListEngineBuildsMissingIngredients() {
        let service = LocalRecipeGenerationService()
        let match = service.generateMatches(
            inventory: [PantryItem(name: "Pasta", category: .grains, location: .pantry, quantity: 1, unit: "box", expiryDate: Date.daysFromNow(30))],
            recipes: SampleData.recipes().filter { $0.title == "Pea Pesto Pasta" },
            preferences: UserPreferences(),
            useExpiringFirst: true
        )[0]

        let shoppingItems = ShoppingListEngine().makeShoppingItems(from: match)

        XCTAssertTrue(shoppingItems.map(\.name).contains("Frozen Peas"))
        XCTAssertTrue(shoppingItems.map(\.name).contains("Lemons"))
    }

    func testNotificationPreviewIncludesExpiringItems() {
        let preview = NotificationScheduler().preview(for: SampleData.pantryItems(), preferences: UserPreferences())

        XCTAssertNotNil(preview)
        XCTAssertTrue(preview?.itemNames.isEmpty == false)
        XCTAssertEqual(preview?.hour, 18)
    }

    func testMarkRecipeCookedConsumesInventoryAndAddsAnalytics() {
        let store = KitchenStore()
        let beforeAnalytics = store.analytics.count
        guard let match = store.recipeMatches().first else {
            return XCTFail("Expected a recipe match")
        }

        store.markCooked(match)

        XCTAssertEqual(store.analytics.count, beforeAnalytics + 1)
        XCTAssertTrue(store.analytics.last?.foodSavedCount ?? 0 > 0)
    }
}
