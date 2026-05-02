import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var store: KitchenStore

    var body: some View {
        ZStack {
            AppBackground()
            if store.onboardingCompleted {
                MainTabView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                OnboardingFlow()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .task {
            store.configure(modelContext: modelContext)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeDashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                InventoryView()
            }
            .tabItem {
                Label("Inventory", systemImage: "refrigerator.fill")
            }

            NavigationStack {
                RecipePlannerView()
            }
            .tabItem {
                Label("Recipes", systemImage: "fork.knife.circle.fill")
            }

            NavigationStack {
                ShoppingListView()
            }
            .tabItem {
                Label("Shopping", systemImage: "cart.fill")
            }

            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(AppTheme.basil)
    }
}

#Preview("Home Dashboard Dark") {
    NavigationStack {
        HomeDashboardView()
            .environmentObject(KitchenStore())
    }
    .preferredColorScheme(.dark)
}

#Preview("Onboarding Large Type") {
    OnboardingFlow()
        .environmentObject(KitchenStore())
        .dynamicTypeSize(.accessibility2)
}
