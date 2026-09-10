import SwiftUI
import UIKit

enum AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.945, blue: 0.90),
            Color(red: 0.985, green: 0.975, blue: 0.945)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let accent = Color(red: 0.12, green: 0.38, blue: 0.31)
    static let accent2 = Color(red: 0.24, green: 0.56, blue: 0.44)
    static let ink = Color(red: 0.12, green: 0.15, blue: 0.13)
    static let muted = Color(red: 0.38, green: 0.42, blue: 0.39)
    static let line = Color(red: 0.18, green: 0.28, blue: 0.22).opacity(0.13)
    static let panel = Color.white.opacity(0.72)
    static let card = LinearGradient(
        colors: [Color.white.opacity(0.96), Color(red: 0.985, green: 0.975, blue: 0.94)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accentGradient = LinearGradient(colors: [accent, accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content() }
            .padding(17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.accent.opacity(0.55))
                    .frame(width: 3)
                    .padding(.vertical, 12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.035), radius: 8, y: 4)
    }
}

struct VolumeHeroIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.accent.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.accent.opacity(0.16))
                }
            Image(systemName: "shippingbox.and.arrow.backward.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.accentGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(AppTheme.accent, in: Circle())
                        .offset(x: 7, y: 6)
                }
        }
        .frame(width: 60, height: 60)
    }
}

struct MetricCard: View {
    let title: String
    let value: Double
    let emphasized: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.subheadline.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(AppTheme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(emphasized ? AppTheme.accent : AppTheme.ink)
                Text("l")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.line)
        }
    }
}

struct NumberField: View {
    let title: String
    let unit: String
    @Binding var value: Double
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(title)).font(.body).foregroundStyle(AppTheme.ink)
            HStack(alignment: .firstTextBaseline) {
                TextField("0", value: $value, format: .number.precision(.fractionLength(0...2)))
                    .keyboardType(.decimalPad)
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityLabel(title + ", " + unit)
                    .focused($focused)
                    .padding(10)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(focused ? AppTheme.accent : AppTheme.line))
                Text(unit).font(.body).foregroundStyle(AppTheme.muted)
            }
        }
    }

}

extension View {
    func dismissKeyboardToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .fontWeight(.semibold)
            }
        }
    }
}


/// Collapse dense ledger rows into a vertical layout for accessibility text.
struct AdaptiveLedgerRow<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let alignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content
    init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment; self.spacing = spacing; self.content = content
    }
    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: spacing, content: content)
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: alignment, spacing: spacing, content: content)
                VStack(alignment: .leading, spacing: spacing, content: content)
            }
        }
    }
}
