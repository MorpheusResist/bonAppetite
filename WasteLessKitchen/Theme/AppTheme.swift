import SwiftUI

enum AppTheme {
    static let basil = Color(red: 0.18, green: 0.48, blue: 0.31)
    static let mint = Color(red: 0.62, green: 0.82, blue: 0.70)
    static let tomato = Color(red: 0.83, green: 0.29, blue: 0.22)
    static let lemon = Color(red: 0.95, green: 0.78, blue: 0.30)
    static let blueberry = Color(red: 0.24, green: 0.34, blue: 0.62)
    static let ink = Color(red: 0.08, green: 0.10, blue: 0.11)
    static let cream = Color(red: 0.96, green: 0.94, blue: 0.89)

    static func riskColor(_ risk: FreshnessRisk) -> Color {
        switch risk {
        case .expired: tomato
        case .today: Color.orange
        case .soon: lemon
        case .fresh: basil
        case .shelfStable: blueberry
        }
    }
}

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                ? [Color(red: 0.05, green: 0.08, blue: 0.07), Color(red: 0.08, green: 0.11, blue: 0.13)]
                : [Color(red: 0.98, green: 0.97, blue: 0.93), Color(red: 0.91, green: 0.96, blue: 0.91)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

struct GlassCard<Content: View>: View {
    let padding: CGFloat
    @ViewBuilder var content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }
}

struct RiskBadge: View {
    let risk: FreshnessRisk
    let text: String

    var body: some View {
        Label(text, systemImage: risk.symbol)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .foregroundStyle(risk == .soon ? .black : .white)
            .background(AppTheme.riskColor(risk), in: Capsule())
            .accessibilityLabel("\(risk.rawValue), \(text)")
    }
}

struct TagPill: View {
    let text: String
    var symbol: String?
    var tint: Color = AppTheme.basil

    var body: some View {
        Label {
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        } icon: {
            if let symbol {
                Image(systemName: symbol)
            }
        }
        .font(.caption.weight(.medium))
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let symbol: String
    var tint: Color = AppTheme.basil

    var body: some View {
        GlassCard(padding: 14) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.weight(.bold))
                .contentTransition(.numericText())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    var tint: Color = AppTheme.basil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .controlSize(.large)
        .accessibilityIdentifier(title.replacingOccurrences(of: " ", with: ""))
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppTheme.basil)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct QuantityStepper: View {
    @Binding var value: Double
    let unit: String

    var body: some View {
        Stepper {
            Text("\(value, specifier: value.rounded() == value ? "%.0f" : "%.1f") \(unit)")
        } onIncrement: {
            value += 1
        } onDecrement: {
            value = max(0, value - 1)
        }
    }
}

extension View {
    func kitchenNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
    }
}
