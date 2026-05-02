import SwiftData
import SwiftUI

@main
struct WasteLessKitchenApp: App {
    @StateObject private var store = KitchenStore()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            PantryItem.self,
            Recipe.self,
            ShoppingItem.self,
            AnalyticsEntry.self,
            CookingSession.self
        ])
        let inMemory = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create WasteLess Kitchen model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
        .modelContainer(modelContainer)
    }
}
