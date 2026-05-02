import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pageCount = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                ProgressView(value: Double(page + 1), total: Double(pageCount))
                    .tint(AppTheme.basil)
                    .accessibilityLabel("Onboarding progress")
                    .accessibilityValue("Step \(page + 1) of \(pageCount)")

                TabView(selection: $page) {
                    HouseholdPage().tag(0)
                    DietPage().tag(1)
                    CookingStylePage().tag(2)
                    NotificationAccessPage().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85), value: page)

                HStack(spacing: 12) {
                    if page > 0 {
                        Button {
                            page -= 1
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                    }

                    PrimaryActionButton(
                        title: page == pageCount - 1 ? "Start Cooking Smarter" : "Continue",
                        systemImage: page == pageCount - 1 ? "checkmark.circle.fill" : "chevron.right"
                    ) {
                        if page == pageCount - 1 {
                            store.completeOnboarding()
                        } else {
                            page += 1
                        }
                    }
                    .accessibilityIdentifier(page == pageCount - 1 ? "FinishOnboarding" : "ContinueOnboarding")
                }
            }
            .padding()
            .navigationTitle("WasteLess Kitchen")
        }
    }
}

private struct HouseholdPage: View {
    @EnvironmentObject private var store: KitchenStore

    var body: some View {
        OnboardingPage(symbol: "house.and.flag.fill", title: "Set up your kitchen", subtitle: "WasteLess Kitchen uses household size and goals to size recipes, reminders, and savings estimates.") {
            GlassCard {
                Stepper(value: $store.preferences.householdSize, in: 1...8) {
                    Label("\(store.preferences.householdSize) people", systemImage: "person.2.fill")
                        .font(.headline)
                }

                Picker("Cooking skill", selection: $store.preferences.cookingSkill) {
                    ForEach(CookingSkill.allCases) { skill in
                        Text(skill.rawValue).tag(skill)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

private struct DietPage: View {
    @EnvironmentObject private var store: KitchenStore

    var body: some View {
        OnboardingPage(symbol: "leaf.fill", title: "Personalize meals", subtitle: "Diet and allergy filters keep recommendations practical instead of just clever.") {
            GlassCard {
                Text("Diet")
                    .font(.headline)
                FlowLayout(items: DietTag.allCases.map(\.rawValue)) { value in
                    let tag = DietTag(rawValue: value)!
                    TogglePill(
                        title: value,
                        isOn: binding(for: tag),
                        symbol: tag == .highProtein ? "bolt.heart" : "checkmark"
                    )
                }

                Divider()

                Text("Allergies")
                    .font(.headline)
                FlowLayout(items: SampleData.allergyOptions) { allergy in
                    TogglePill(title: allergy, isOn: allergyBinding(for: allergy), symbol: "exclamationmark.shield")
                }
            }
        }
    }

    private func binding(for diet: DietTag) -> Binding<Bool> {
        Binding {
            store.preferences.selectedDiets.contains(diet)
        } set: { isOn in
            if isOn {
                store.preferences.selectedDiets.insert(diet)
            } else {
                store.preferences.selectedDiets.remove(diet)
            }
        }
    }

    private func allergyBinding(for allergy: String) -> Binding<Bool> {
        Binding {
            store.preferences.allergies.contains(allergy)
        } set: { isOn in
            if isOn {
                store.preferences.allergies.insert(allergy)
            } else {
                store.preferences.allergies.remove(allergy)
            }
        }
    }
}

private struct CookingStylePage: View {
    @EnvironmentObject private var store: KitchenStore

    var body: some View {
        OnboardingPage(symbol: "fork.knife", title: "Tune dinner suggestions", subtitle: "The app ranks meals by expiring food, time, budget, cuisine, and equipment.") {
            GlassCard {
                Picker("Budget", selection: $store.preferences.budget) {
                    ForEach(BudgetLevel.allCases) { budget in
                        Text(budget.rawValue).tag(budget)
                    }
                }
                .pickerStyle(.segmented)

                Text("Favorite cuisines")
                    .font(.headline)
                FlowLayout(items: SampleData.cuisineOptions) { cuisine in
                    TogglePill(title: cuisine, isOn: cuisineBinding(for: cuisine), symbol: "globe")
                }
            }
        }
    }

    private func cuisineBinding(for cuisine: String) -> Binding<Bool> {
        Binding {
            store.preferences.preferredCuisines.contains(cuisine)
        } set: { isOn in
            if isOn {
                store.preferences.preferredCuisines.insert(cuisine)
            } else {
                store.preferences.preferredCuisines.remove(cuisine)
            }
        }
    }
}

private struct NotificationAccessPage: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var requestedNotifications = false

    var body: some View {
        OnboardingPage(symbol: "bell.badge.fill", title: "Make it usable in a real kitchen", subtitle: "Expiry reminders, larger cooking text, and read-aloud support help while your hands are busy.") {
            GlassCard {
                Picker("Reminder style", selection: $store.preferences.notificationStyle) {
                    ForEach(NotificationStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.menu)

                Toggle("Large cooking instructions", isOn: $store.preferences.prefersLargeCookingText)
                Toggle("High contrast freshness badges", isOn: $store.preferences.prefersHighContrast)
                Toggle("Rounded dyslexia-friendly text", isOn: $store.preferences.prefersDyslexiaFont)
                Toggle("Reduce app motion", isOn: $store.preferences.reduceMotionInApp)

                Button {
                    requestedNotifications = true
                    Task { await store.requestAndScheduleNotifications() }
                } label: {
                    Label(requestedNotifications ? "Reminder Preview Ready" : "Enable Expiry Reminders", systemImage: "bell.and.waves.left.and.right")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.blueberry)
                .accessibilityHint("Requests notification permission and schedules daily expiry reminders.")
            }
        }
    }
}

private struct OnboardingPage<Content: View>: View {
    let symbol: String
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: symbol)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(AppTheme.basil)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)

                content
            }
            .padding(.vertical, 18)
        }
    }
}

private struct TogglePill: View {
    let title: String
    @Binding var isOn: Bool
    let symbol: String

    var body: some View {
        Button {
            isOn.toggle()
            Haptics.light()
        } label: {
            Label(title, systemImage: isOn ? symbol : "plus")
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .foregroundStyle(isOn ? .white : AppTheme.basil)
                .background(isOn ? AppTheme.basil : AppTheme.basil.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? "Selected" : "Not selected")
    }
}

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}
