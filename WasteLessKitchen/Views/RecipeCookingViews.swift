import SwiftUI

struct RecipePlannerView: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var useExpiringFirst = true
    @State private var maxMinutes = 35.0
    @State private var maxCalories = 850.0
    @State private var minProtein = 0.0
    @State private var selectedCuisine = "Any"
    @State private var selectedEquipment = "Any"
    @State private var selectedMatch: RecipeMatch?
    @State private var cookingMatch: RecipeMatch?

    private var matches: [RecipeMatch] {
        store.recipeMatches(useExpiringFirst: useExpiringFirst)
            .filter { Double($0.recipe.cookTimeMinutes) <= maxMinutes }
            .filter { Double($0.recipe.calories) <= maxCalories }
            .filter { Double($0.recipe.protein) >= minProtein }
            .filter { selectedCuisine == "Any" || $0.recipe.cuisine == selectedCuisine }
            .filter { selectedEquipment == "Any" || $0.recipe.equipment.contains(selectedEquipment) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                filters
                if matches.isEmpty {
                    EmptyStateView(symbol: "fork.knife", title: "No recipes match", message: "Loosen your filters or add more inventory.")
                } else {
                    ForEach(matches) { match in
                        RecipeCard(match: match) {
                            selectedMatch = match
                        } cook: {
                            cookingMatch = match
                        } shop: {
                            store.addMissingIngredientsToShopping(from: match)
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppBackground())
        .kitchenNavigationTitle("Recipes")
        .sheet(item: $selectedMatch) { match in
            NavigationStack { RecipeDetailView(match: match, cookingMatch: $cookingMatch) }
        }
        .sheet(item: $cookingMatch) { match in
            CookingModeView(match: match)
        }
    }

    private var filters: some View {
        GlassCard {
            Toggle("Use expiring food first", isOn: $useExpiringFirst)
                .font(.headline)
                .accessibilityIdentifier("UseExpiringFirstToggle")

            VStack(alignment: .leading) {
                Text("Cook time: up to \(Int(maxMinutes)) min")
                    .font(.subheadline.weight(.semibold))
                Slider(value: $maxMinutes, in: 10...60, step: 5)
                    .tint(AppTheme.basil)
            }

            VStack(alignment: .leading) {
                Text("Calories: up to \(Int(maxCalories))")
                    .font(.subheadline.weight(.semibold))
                Slider(value: $maxCalories, in: 300...900, step: 50)
                    .tint(.orange)
            }

            VStack(alignment: .leading) {
                Text("Protein: at least \(Int(minProtein))g")
                    .font(.subheadline.weight(.semibold))
                Slider(value: $minProtein, in: 0...45, step: 5)
                    .tint(AppTheme.blueberry)
            }

            Picker("Cuisine", selection: $selectedCuisine) {
                Text("Any").tag("Any")
                ForEach(SampleData.cuisineOptions, id: \.self) { cuisine in
                    Text(cuisine).tag(cuisine)
                }
            }
            .pickerStyle(.menu)

            Picker("Equipment", selection: $selectedEquipment) {
                Text("Any").tag("Any")
                ForEach(SampleData.equipmentOptions, id: \.self) { equipment in
                    Text(equipment).tag(equipment)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct RecipeCard: View {
    let match: RecipeMatch
    let open: () -> Void
    let cook: () -> Void
    let shop: () -> Void

    var body: some View {
        GlassCard {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(match.recipe.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(match.recipe.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(AppTheme.basil.opacity(0.22), lineWidth: 7)
                            Circle()
                                .trim(from: 0, to: match.score)
                                .stroke(AppTheme.basil, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Text("\(match.matchPercentage)%")
                                .font(.caption.weight(.bold))
                        }
                        .frame(width: 58, height: 58)
                        .accessibilityLabel("\(match.matchPercentage) percent match")
                    }

                    Text(match.explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(recipeTags.indices, id: \.self) { index in
                            let tag = recipeTags[index]
                            TagPill(text: tag.text, symbol: tag.symbol, tint: tag.tint)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            HStack {
                Button(action: cook) {
                    Label("Cook", systemImage: "play.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.basil)

                Button(action: shop) {
                    Label(match.missingIngredients.isEmpty ? "Complete" : "Add \(match.missingIngredients.count)", systemImage: "cart.badge.plus")
                }
                .buttonStyle(.bordered)
                .disabled(match.missingIngredients.isEmpty)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var recipeTags: [(text: String, symbol: String, tint: Color)] {
        var tags: [(text: String, symbol: String, tint: Color)] = [
            ("\(match.recipe.cookTimeMinutes) min", "clock", AppTheme.blueberry),
            ("\(match.recipe.calories) cal", "flame", .orange),
            ("\(match.recipe.protein)g protein", "bolt.heart", AppTheme.tomato)
        ]
        if !match.missingIngredients.isEmpty {
            tags.append(("\(match.missingIngredients.count) missing", "minus.circle", .gray))
        }
        if !match.expiringIngredients.isEmpty {
            tags.append(("Uses expiring food", "clock.badge.exclamationmark", .orange))
        }
        return tags
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.dismiss) private var dismiss
    let match: RecipeMatch
    @Binding var cookingMatch: RecipeMatch?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassCard {
                    Text(match.recipe.title)
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(match.explanation)
                        .foregroundStyle(.secondary)
                    FlowLayout(items: match.recipe.dietTags.map(\.rawValue)) { tag in
                        TagPill(text: tag, symbol: "leaf", tint: AppTheme.basil)
                    }
                }

                ingredientSection
                stepsSection

                PrimaryActionButton(title: "Start Cooking Mode", systemImage: "play.fill") {
                    dismiss()
                    cookingMatch = match
                }
                Button {
                    store.addMissingIngredientsToShopping(from: match)
                } label: {
                    Label("Add Missing Ingredients", systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(match.missingIngredients.isEmpty)
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ingredientSection: some View {
        GlassCard {
            Text("Ingredients")
                .font(.headline)
            ForEach(match.recipe.ingredients, id: \.self) { ingredient in
                HStack {
                    let hasIt = match.matchedIngredients.contains(where: { $0.caseInsensitiveCompare(ingredient) == .orderedSame })
                    Image(systemName: hasIt ? "checkmark.circle.fill" : "plus.circle")
                        .foregroundStyle(hasIt ? AppTheme.basil : .secondary)
                    Text(ingredient)
                    Spacer()
                    if match.expiringIngredients.contains(where: { $0.caseInsensitiveCompare(ingredient) == .orderedSame }) {
                        TagPill(text: "Use soon", symbol: "clock", tint: .orange)
                    }
                }
            }
        }
    }

    private var stepsSection: some View {
        GlassCard {
            Text("Steps")
                .font(.headline)
            ForEach(match.recipe.cookingSteps) { step in
                HStack(alignment: .top) {
                    Text("\(step.order)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(AppTheme.basil)
                        .frame(width: 28)
                    Text(step.instruction)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct CookingModeView: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var reader = SpeechCookingReader()
    @State private var stepIndex = 0
    @State private var remainingSeconds = 0
    @State private var timerTask: Task<Void, Never>?
    let match: RecipeMatch

    private var steps: [CookingStep] { match.recipe.cookingSteps }
    private var currentStep: CookingStep { steps[min(stepIndex, max(steps.count - 1, 0))] }
    private var fontSize: CGFloat { store.preferences.prefersLargeCookingText ? 31 : 24 }

    var body: some View {
        VStack(spacing: 18) {
            ProgressView(value: Double(stepIndex + 1), total: Double(max(steps.count, 1)))
                .tint(AppTheme.basil)
                .accessibilityLabel("Cooking progress")
                .accessibilityValue("Step \(stepIndex + 1) of \(steps.count)")

            GlassCard(padding: 20) {
                HStack {
                    Label("Step \(stepIndex + 1) of \(steps.count)", systemImage: "hands.sparkles.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.basil)
                    Spacer()
                    if currentStep.minutes > 0 {
                        TagPill(text: "\(currentStep.minutes) min", symbol: "timer", tint: AppTheme.blueberry)
                    }
                }

                Text(currentStep.instruction)
                    .font(.system(size: fontSize, weight: .bold, design: store.preferences.prefersDyslexiaFont ? .rounded : .default))
                    .lineSpacing(6)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("CookingInstruction")

                if remainingSeconds > 0 {
                    Text(timerText)
                        .font(.system(size: 44, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(AppTheme.tomato)
                        .accessibilityLabel("Timer \(timerText)")
                }
            }
            .animation(reduceMotion || store.preferences.reduceMotionInApp ? nil : .spring(response: 0.32, dampingFraction: 0.8), value: stepIndex)

            controls

            GlassCard(padding: 14) {
                Text("Using")
                    .font(.headline)
                FlowLayout(items: match.matchedIngredients) { ingredient in
                    TagPill(text: ingredient, symbol: "checkmark", tint: AppTheme.basil)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(AppBackground())
        .navigationTitle(match.recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Cooked") {
                    store.markCooked(match)
                    dismiss()
                }
                .accessibilityIdentifier("MarkRecipeCooked")
            }
        }
        .onDisappear {
            timerTask?.cancel()
            reader.stop()
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    previous()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(stepIndex == 0)
                .accessibilityLabel("Previous step")
                .accessibilityIdentifier("PreviousCookingStep")

                Button {
                    if reader.isSpeaking {
                        reader.stop()
                    } else {
                        reader.speak(currentStep.instruction)
                    }
                } label: {
                    Image(systemName: reader.isSpeaking ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                        .font(.system(size: 44))
                }
                .accessibilityLabel(reader.isSpeaking ? "Stop reading step" : "Read step aloud")

                Button {
                    startTimer(minutes: currentStep.minutes)
                } label: {
                    Image(systemName: remainingSeconds > 0 ? "timer.circle.fill" : "timer")
                        .font(.system(size: 44))
                }
                .disabled(currentStep.minutes == 0)
                .accessibilityLabel("Start step timer")

                Button {
                    next()
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(stepIndex >= steps.count - 1)
                .accessibilityLabel("Next step")
                .accessibilityIdentifier("NextCookingStep")
            }

            Text("Voice controls: say next, previous, or repeat when Speech is enabled in a production build.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppTheme.basil)
    }

    private var timerText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    private func previous() {
        stepIndex = max(0, stepIndex - 1)
        remainingSeconds = 0
        timerTask?.cancel()
        Haptics.light()
    }

    private func next() {
        stepIndex = min(steps.count - 1, stepIndex + 1)
        remainingSeconds = 0
        timerTask?.cancel()
        Haptics.light()
    }

    private func startTimer(minutes: Int) {
        guard minutes > 0 else { return }
        timerTask?.cancel()
        remainingSeconds = minutes * 60
        timerTask = Task {
            while !Task.isCancelled && remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    remainingSeconds -= 1
                    if remainingSeconds == 0 {
                        Haptics.success()
                    }
                }
            }
        }
    }
}
