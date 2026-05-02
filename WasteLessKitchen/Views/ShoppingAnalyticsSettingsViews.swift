import Charts
import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var newItemName = ""
    @State private var newItemCategory: FoodCategory = .produce

    private var groupedItems: [(FoodCategory, [ShoppingItem])] {
        Dictionary(grouping: store.shoppingItems, by: \.category)
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
            .sorted { $0.0.rawValue < $1.0.rawValue }
    }

    var body: some View {
        List {
            Section {
                GlassCard {
                    TextField("Add grocery item", text: $newItemName)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("ShoppingItemName")
                    Picker("Category", selection: $newItemCategory) {
                        ForEach(FoodCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    PrimaryActionButton(title: "Add to List", systemImage: "plus.circle.fill") {
                        store.addShoppingItem(name: newItemName, category: newItemCategory)
                        newItemName = ""
                    }
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("AddShoppingItem")
                }
                .listRowBackground(Color.clear)
            }

            if store.shoppingItems.isEmpty {
                EmptyStateView(symbol: "cart", title: "Shopping list is clear", message: "Missing recipe ingredients will appear here.")
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(groupedItems, id: \.0) { category, items in
                    Section(category.rawValue) {
                        ForEach(items) { item in
                            ShoppingRow(item: item)
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if store.shoppingItems.contains(where: { $0.isChecked }) {
                PrimaryActionButton(title: "Move Purchased to Inventory", systemImage: "arrow.down.circle.fill", tint: AppTheme.blueberry) {
                    store.convertPurchasedToInventory()
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .kitchenNavigationTitle("Shopping")
    }
}

private struct ShoppingRow: View {
    @EnvironmentObject private var store: KitchenStore
    let item: ShoppingItem

    var body: some View {
        Button {
            store.toggleShoppingItem(item)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? AppTheme.basil : .secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.headline)
                        .strikethrough(item.isChecked)
                    Text("\(item.quantity, specifier: "%.0f") \(item.unit) • \(item.source)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: item.category.symbol)
                    .foregroundStyle(AppTheme.basil)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.name), \(item.isChecked ? "checked" : "not checked")")
    }
}

struct AnalyticsView: View {
    @EnvironmentObject private var store: KitchenStore

    private var savedTotal: Double {
        store.analytics.reduce(0) { $0 + $1.moneySaved }
    }

    private var wastedTotal: Int {
        store.analytics.reduce(0) { $0 + $1.wastedCount }
    }

    private var savedCount: Int {
        store.analytics.reduce(0) { $0 + $1.foodSavedCount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricTile(title: "Food saved", value: "\(savedCount)", symbol: "leaf.arrow.circlepath", tint: AppTheme.basil)
                    MetricTile(title: "Money saved", value: "$\(Int(savedTotal))", symbol: "dollarsign.circle.fill", tint: AppTheme.blueberry)
                    MetricTile(title: "Items wasted", value: "\(wastedTotal)", symbol: "trash.slash.fill", tint: AppTheme.tomato)
                    MetricTile(title: "Pantry score", value: "\(pantryScore)", symbol: "gauge.with.dots.needle.bottom.50percent", tint: .orange)
                }

                savingsChart
                wasteChart
                nutritionCard
                categoryBreakdown
            }
            .padding()
        }
        .background(AppBackground())
        .kitchenNavigationTitle("Analytics")
    }

    private var pantryScore: Int {
        let total = max(savedCount + wastedTotal, 1)
        return Int((Double(savedCount) / Double(total) * 100).rounded())
    }

    private var savingsChart: some View {
        GlassCard {
            Text("Savings Trend")
                .font(.headline)
            Chart(store.analytics.suffix(14)) { entry in
                LineMark(
                    x: .value("Day", entry.date),
                    y: .value("Saved", entry.moneySaved)
                )
                .foregroundStyle(AppTheme.basil)
                AreaMark(
                    x: .value("Day", entry.date),
                    y: .value("Saved", entry.moneySaved)
                )
                .foregroundStyle(AppTheme.basil.opacity(0.16))
            }
            .frame(height: 190)
            .chartXAxis(.hidden)
            .accessibilityLabel("Money saved chart")
        }
    }

    private var wasteChart: some View {
        GlassCard {
            Text("Saved vs Wasted")
                .font(.headline)
            Chart(store.analytics.suffix(10)) { entry in
                BarMark(x: .value("Day", entry.date, unit: .day), y: .value("Saved", entry.foodSavedCount))
                    .foregroundStyle(AppTheme.basil)
                BarMark(x: .value("Day", entry.date, unit: .day), y: .value("Wasted", entry.wastedCount))
                    .foregroundStyle(AppTheme.tomato)
            }
            .frame(height: 190)
            .chartXAxis(.hidden)
            .accessibilityLabel("Food saved and wasted chart")
        }
    }

    private var nutritionCard: some View {
        let summary = store.nutritionSummary()
        return GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nutrition Overview")
                        .font(.headline)
                    Text("\(summary.calories) calories and \(summary.protein)g protein available in current inventory.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "heart.text.square.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.tomato)
            }
            ProgressView(value: Double(summary.protein), total: Double(max(store.preferences.dailyProteinGoal, 1)))
                .tint(AppTheme.blueberry)
                .accessibilityLabel("Protein inventory compared with daily goal")
        }
    }

    private var categoryBreakdown: some View {
        let grouped = Dictionary(grouping: store.analytics, by: \.category)
            .map { category, entries in
                (category, entries.reduce(0) { $0 + $1.wastedCount })
            }
            .sorted { $0.1 > $1.1 }

        return GlassCard {
            Text("Most Wasted Categories")
                .font(.headline)
            ForEach(grouped.prefix(5), id: \.0) { category, count in
                HStack {
                    Label(category.rawValue, systemImage: category.symbol)
                    Spacer()
                    Text("\(count)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(count == 0 ? AppTheme.basil : AppTheme.tomato)
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var showingExport = false
    @State private var exportText = ""

    var body: some View {
        Form {
            Section("Household") {
                Stepper("Household size: \(store.preferences.householdSize)", value: $store.preferences.householdSize, in: 1...8)
                Picker("Skill", selection: $store.preferences.cookingSkill) {
                    ForEach(CookingSkill.allCases) { skill in
                        Text(skill.rawValue).tag(skill)
                    }
                }
                Picker("Budget", selection: $store.preferences.budget) {
                    ForEach(BudgetLevel.allCases) { budget in
                        Text(budget.rawValue).tag(budget)
                    }
                }
            }

            Section("Nutrition Goals") {
                Stepper("Protein goal: \(store.preferences.dailyProteinGoal)g", value: $store.preferences.dailyProteinGoal, in: 40...180, step: 5)
                Stepper("Calorie goal: \(store.preferences.dailyCalorieGoal)", value: $store.preferences.dailyCalorieGoal, in: 1200...3600, step: 100)
            }

            Section("Diet") {
                ForEach(DietTag.allCases) { diet in
                    Toggle(diet.rawValue, isOn: dietBinding(for: diet))
                }
            }

            Section("Allergens") {
                ForEach(SampleData.allergyOptions, id: \.self) { allergy in
                    Toggle(allergy, isOn: allergyBinding(for: allergy))
                }
            }

            Section("Notifications") {
                Picker("Reminder style", selection: $store.preferences.notificationStyle) {
                    ForEach(NotificationStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                Button {
                    Task { await store.requestAndScheduleNotifications() }
                } label: {
                    Label("Schedule Expiry Reminder", systemImage: "bell.badge")
                }
                if let preview = store.notificationPreview() {
                    Text(preview.body)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Accessibility") {
                Toggle("Large cooking text", isOn: $store.preferences.prefersLargeCookingText)
                Toggle("High contrast badges", isOn: $store.preferences.prefersHighContrast)
                Toggle("Rounded dyslexia-friendly text", isOn: $store.preferences.prefersDyslexiaFont)
                Toggle("Reduce app motion", isOn: $store.preferences.reduceMotionInApp)
            }

            Section("Data") {
                Button {
                    exportText = store.exportSummary()
                    showingExport = true
                } label: {
                    Label("Export Summary", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    store.resetDemoData()
                } label: {
                    Label("Reset Demo Data", systemImage: "arrow.counterclockwise")
                }

                Button {
                    store.resetOnboardingForDemo()
                } label: {
                    Label("Replay Onboarding", systemImage: "rectangle.on.rectangle")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .kitchenNavigationTitle("Settings")
        .onDisappear {
            store.savePreferences()
        }
        .sheet(isPresented: $showingExport) {
            NavigationStack {
                ScrollView {
                    Text(exportText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .navigationTitle("Export")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showingExport = false }
                    }
                }
            }
        }
    }

    private func dietBinding(for diet: DietTag) -> Binding<Bool> {
        Binding {
            store.preferences.selectedDiets.contains(diet)
        } set: { isOn in
            if isOn {
                store.preferences.selectedDiets.insert(diet)
            } else {
                store.preferences.selectedDiets.remove(diet)
            }
            store.savePreferences()
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
            store.savePreferences()
        }
    }
}
