import AppIntents
import Foundation

struct CookTonightIntent: AppIntent {
    static var title: LocalizedStringResource = "What can I cook tonight?"
    static var description = IntentDescription("Suggests the best recipe from the current demo pantry, prioritizing expiring ingredients.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = LocalRecipeGenerationService()
        let match = service.generateMatches(
            inventory: SampleData.pantryItems(),
            recipes: SampleData.recipes(),
            preferences: UserPreferences(),
            useExpiringFirst: true
        ).first
        let title = match?.recipe.title ?? "a pantry bowl"
        let reason = match?.explanation ?? "It uses what is already in your kitchen."
        return .result(dialog: "Cook \(title) tonight. \(reason)")
    }
}

struct ExpiringSoonIntent: AppIntent {
    static var title: LocalizedStringResource = "What is expiring soon?"
    static var description = IntentDescription("Lists food that should be used soon.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let items = ExpiryRiskEngine().expiringSoon(from: SampleData.pantryItems()).prefix(5).map(\.name)
        let text = items.isEmpty ? "Nothing is urgent today." : "Use \(items.joined(separator: ", ")) soon."
        return .result(dialog: "\(text)")
    }
}

struct AddShoppingItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add item to shopping list"
    static var description = IntentDescription("Adds a grocery item to the shopping list when run inside the app shortcut flow.")
    static var openAppWhenRun = true

    @Parameter(title: "Item")
    var item: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let name = item.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = name.isEmpty ? "Open WasteLess Kitchen to add an item." : "\(name) is ready to add to your shopping list."
        return .result(dialog: "\(text)")
    }
}

struct StartCookingModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Start cooking mode"
    static var description = IntentDescription("Opens WasteLess Kitchen so you can begin the hands-free cooking flow.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Opening WasteLess Kitchen cooking mode.")
    }
}

struct WasteLessKitchenShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .green

    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: CookTonightIntent(),
                phrases: [
                    "What can I cook tonight with \(.applicationName)",
                    "Cook tonight with \(.applicationName)"
                ],
                shortTitle: "Cook Tonight",
                systemImageName: "fork.knife"
            ),
            AppShortcut(
                intent: ExpiringSoonIntent(),
                phrases: [
                    "What is expiring soon in \(.applicationName)",
                    "Check expiring food with \(.applicationName)"
                ],
                shortTitle: "Expiring Soon",
                systemImageName: "clock.badge.exclamationmark"
            ),
            AppShortcut(
                intent: AddShoppingItemIntent(),
                phrases: [
                    "Add \(\.$item) to my \(.applicationName) shopping list",
                    "Add \(\.$item) in \(.applicationName)"
                ],
                shortTitle: "Add Grocery",
                systemImageName: "cart.badge.plus"
            ),
            AppShortcut(
                intent: StartCookingModeIntent(),
                phrases: [
                    "Start cooking mode in \(.applicationName)",
                    "Open cooking mode with \(.applicationName)"
                ],
                shortTitle: "Cooking Mode",
                systemImageName: "speaker.wave.2.circle"
            )
        ]
    }
}
