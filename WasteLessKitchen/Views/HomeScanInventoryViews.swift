import PhotosUI
import SwiftUI
import UIKit

struct HomeDashboardView: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var showingScan = false
    @State private var cookingMatch: RecipeMatch?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                quickMetrics
                expiringCarousel
                inventorySummary
            }
            .padding()
        }
        .background(AppBackground())
        .kitchenNavigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingScan = true
                } label: {
                    Image(systemName: "camera.viewfinder")
                }
                .accessibilityLabel("Scan food")
            }
        }
        .sheet(isPresented: $showingScan) {
            NavigationStack { ScanFlowView() }
        }
        .sheet(item: $cookingMatch) { match in
            CookingModeView(match: match)
        }
    }

    private var hero: some View {
        GlassCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Cook Tonight", systemImage: "sparkles")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.basil)

                    if let match = store.topRecipeMatch() {
                        Text(match.recipe.title)
                            .font(.largeTitle.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(match.explanation)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack {
                            TagPill(text: "\(match.matchPercentage)% match", symbol: "checkmark.seal.fill", tint: AppTheme.basil)
                            if !match.expiringIngredients.isEmpty {
                                TagPill(text: "Uses expiring food", symbol: "clock.badge.exclamationmark", tint: .orange)
                            }
                        }

                        HStack {
                            Button {
                                cookingMatch = match
                            } label: {
                                Label("Start", systemImage: "play.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.basil)
                            .accessibilityIdentifier("StartCookingMode")

                            Button {
                                store.addMissingIngredientsToShopping(from: match)
                            } label: {
                                Label("Shop gaps", systemImage: "cart.badge.plus")
                            }
                            .buttonStyle(.bordered)
                            .disabled(match.missingIngredients.isEmpty)
                        }
                    }
                }
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(AppTheme.lemon, AppTheme.basil)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var quickMetrics: some View {
        let summary = store.nutritionSummary()
        let saved = store.analytics.reduce(0) { $0 + $1.moneySaved }
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricTile(title: "Expiring", value: "\(store.expiringSoon().count)", symbol: "clock.badge.exclamationmark", tint: .orange)
            MetricTile(title: "Saved", value: "$\(Int(saved))", symbol: "dollarsign.arrow.circlepath", tint: AppTheme.basil)
            MetricTile(title: "Protein", value: "\(summary.protein)g", symbol: "bolt.heart.fill", tint: AppTheme.blueberry)
            MetricTile(title: "Inventory", value: "\(store.inventory.filter { $0.status == .available }.count)", symbol: "cabinet.fill", tint: AppTheme.tomato)
        }
    }

    private var expiringCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Expiring Soon")
            if store.expiringSoon().isEmpty {
                EmptyStateView(symbol: "checkmark.seal", title: "Nothing urgent", message: "Your kitchen is calm today.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.expiringSoon()) { item in
                            GlassCard(padding: 14) {
                                Label(item.name, systemImage: item.category.symbol)
                                    .font(.headline)
                                Text("\(item.quantity, specifier: "%.0f") \(item.unit) in \(item.location.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                RiskBadge(risk: store.risk(for: item), text: store.badgeText(for: item))
                            }
                            .frame(width: 190)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var inventorySummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Kitchen Inventory")
            ForEach(FoodLocation.allCases.filter { $0 != .shopping }) { location in
                let count = store.inventory.filter { $0.location == location && $0.status == .available }.count
                GlassCard(padding: 12) {
                    HStack {
                        Label(location.rawValue, systemImage: location.symbol)
                            .font(.headline)
                        Spacer()
                        Text("\(count)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct ScanFlowView: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var drafts: [ItemDraft] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassCard {
                    Label("Smart Scan", systemImage: store.selectedScanMode.symbol)
                        .font(.title2.weight(.bold))
                    Text("Choose a scan mode, add a camera/photo sample, then confirm what the local AI detected.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Scan mode", selection: $store.selectedScanMode) {
                        ForEach(ScanMode.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.symbol).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("ScanModePicker")

                    HStack {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Photo", systemImage: "photo.on.rectangle")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showingCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            Task { await store.scanSelectedImage(data: nil) }
                        } label: {
                            Label("Demo Scan", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.basil)
                        .accessibilityIdentifier("DemoScan")
                    }
                }

                if store.isScanning {
                    GlassCard {
                        ProgressView("Detecting ingredients...")
                            .tint(AppTheme.basil)
                    }
                }

                if let scanError = store.scanError {
                    EmptyStateView(symbol: "exclamationmark.triangle", title: "Scan needs a retry", message: scanError)
                }

                if !drafts.isEmpty {
                    SectionHeader(title: "Confirm Detected Items")
                    ForEach($drafts) { $draft in
                        ItemEditorCard(draft: $draft, compact: true)
                    }

                    PrimaryActionButton(title: "Add \(drafts.count) Items", systemImage: "plus.circle.fill") {
                        drafts.forEach(store.addItem)
                        dismiss()
                    }
                    .accessibilityIdentifier("ConfirmDetectedItems")
                }
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Scan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                let data = try? await newItem.loadTransferable(type: Data.self)
                await store.scanSelectedImage(data: data)
            }
        }
        .onChange(of: store.detectedIngredients) { _, detections in
            drafts = detections.map(ItemDraft.init(detected:))
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                let data = image.jpegData(compressionQuality: 0.75)
                Task { await store.scanSelectedImage(data: data) }
            }
        }
    }
}

struct InventoryView: View {
    @EnvironmentObject private var store: KitchenStore
    @State private var location: FoodLocation = .fridge
    @State private var searchText = ""
    @State private var showingManualEntry = false
    @State private var editItem: PantryItem?

    private var filteredItems: [PantryItem] {
        store.inventory
            .filter { $0.status == .available }
            .filter { $0.location == location }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted {
                let left = $0.expiryDate ?? .distantFuture
                let right = $1.expiryDate ?? .distantFuture
                return left < right
            }
    }

    var body: some View {
        List {
            Section {
                Picker("Location", selection: $location) {
                    ForEach(FoodLocation.allCases.filter { $0 != .shopping }) { location in
                        Label(location.rawValue, systemImage: location.symbol).tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
            }

            if filteredItems.isEmpty {
                EmptyStateView(symbol: location.symbol, title: "No \(location.rawValue.lowercased()) items", message: "Scan or add food manually to build this list.")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                Section(location.rawValue) {
                    ForEach(filteredItems) { item in
                        InventoryRow(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture { editItem = item }
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.consume(item)
                                } label: {
                                    Label("Consumed", systemImage: "checkmark.circle")
                                }
                                .tint(AppTheme.basil)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.discard(item)
                                } label: {
                                    Label("Discard", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .searchable(text: $searchText, prompt: "Find an ingredient")
        .kitchenNavigationTitle("Inventory")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingManualEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Add item manually")
                .accessibilityIdentifier("AddManualItem")
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            NavigationStack {
                ManualItemEntryView()
            }
        }
        .sheet(item: $editItem) { item in
            NavigationStack {
                EditItemView(item: item)
            }
        }
    }
}

struct InventoryRow: View {
    @EnvironmentObject private var store: KitchenStore
    let item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.symbol)
                .font(.title3)
                .frame(width: 34, height: 34)
                .foregroundStyle(AppTheme.basil)
                .background(AppTheme.basil.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.quantity, specifier: item.quantity.rounded() == item.quantity ? "%.0f" : "%.1f") \(item.unit) • \(item.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            RiskBadge(risk: store.risk(for: item), text: store.badgeText(for: item))
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name), \(item.quantity) \(item.unit), \(store.risk(for: item).rawValue)")
    }
}

struct ManualItemEntryView: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ItemDraft()

    var body: some View {
        ScrollView {
            ItemEditorCard(draft: $draft)
                .padding()
        }
        .background(AppBackground())
        .navigationTitle("Add Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    store.addItem(draft)
                    dismiss()
                }
                .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityIdentifier("SaveManualItem")
            }
        }
    }
}

struct EditItemView: View {
    @EnvironmentObject private var store: KitchenStore
    @Environment(\.dismiss) private var dismiss
    let item: PantryItem
    @State private var draft: ItemDraft

    init(item: PantryItem) {
        self.item = item
        _draft = State(initialValue: ItemDraft(item: item))
    }

    var body: some View {
        ScrollView {
            ItemEditorCard(draft: $draft)
                .padding()
        }
        .background(AppBackground())
        .navigationTitle("Edit Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    store.updateItem(id: item.id, draft: draft)
                    dismiss()
                }
            }
        }
    }
}

struct ItemEditorCard: View {
    @Binding var draft: ItemDraft
    var compact = false

    private var expiryBinding: Binding<Date> {
        Binding {
            draft.expiryDate ?? Date.daysFromNow(7)
        } set: { value in
            draft.expiryDate = value
        }
    }

    private var hasExpiryBinding: Binding<Bool> {
        Binding {
            draft.expiryDate != nil
        } set: { hasExpiry in
            draft.expiryDate = hasExpiry ? Date.daysFromNow(7) : nil
        }
    }

    var body: some View {
        GlassCard {
            TextField("Item name", text: $draft.name)
                .textInputAutocapitalization(.words)
                .font(.headline)
                .accessibilityIdentifier("ManualItemName")

            HStack {
                Picker("Category", selection: $draft.category) {
                    ForEach(FoodCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                Picker("Location", selection: $draft.location) {
                    ForEach(FoodLocation.allCases.filter { $0 != .shopping }) { location in
                        Text(location.rawValue).tag(location)
                    }
                }
            }
            .pickerStyle(.menu)

            QuantityStepper(value: $draft.quantity, unit: draft.unit)
            TextField("Unit", text: $draft.unit)
                .textInputAutocapitalization(.never)

            Toggle("Track expiry", isOn: hasExpiryBinding)
            if draft.expiryDate != nil {
                DatePicker("Expiry", selection: expiryBinding, displayedComponents: .date)
            }

            if !compact {
                HStack {
                    TextField("Price", value: $draft.priceEstimate, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    TextField("Protein", value: $draft.proteinPerUnit, format: .number)
                        .keyboardType(.decimalPad)
                }
                TextField("Notes", text: $draft.notes, axis: .vertical)
            } else {
                TagPill(text: "\(Int(draft.confidence * 100))% confidence", symbol: "sparkles", tint: AppTheme.blueberry)
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImage: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImage: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImage = onImage
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImage(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
