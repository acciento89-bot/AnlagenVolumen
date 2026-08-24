import SwiftUI
import UIKit

enum AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.012, green: 0.035, blue: 0.055),
            Color(red: 0.018, green: 0.075, blue: 0.085)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accent = Color(red: 0.18, green: 0.82, blue: 0.70)
    static let accent2 = Color(red: 0.30, green: 0.92, blue: 0.80)
    static let muted = Color.white.opacity(0.66)
    static let line = Color.white.opacity(0.09)
    static let panel = Color.white.opacity(0.055)
    static let card = LinearGradient(colors: [Color.white.opacity(0.075), Color.white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let accentGradient = LinearGradient(colors: [accent, accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content() }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(AppTheme.line, lineWidth: 1) }
    }
}

struct VolumeHeroIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.accent.opacity(0.13))
            Image(systemName: "drop.fill")
                .font(.system(size: 33, weight: .bold))
                .foregroundStyle(AppTheme.accentGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "ruler.fill")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.black.opacity(0.75))
                        .padding(6)
                        .background(AppTheme.accent, in: Circle())
                        .offset(x: 8, y: 6)
                }
        }
        .frame(width: 62, height: 62)
    }
}

struct MetricCard: View {
    let title: String
    let value: Double
    let emphasized: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption).foregroundStyle(AppTheme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(.system(size: emphasized ? 34 : 25, weight: .bold, design: .rounded))
                    .foregroundStyle(emphasized ? AppTheme.accent : .white)
                Text("l").font(.subheadline.bold()).foregroundStyle(AppTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct NumberField: View {
    let title: String
    let unit: String
    @Binding var value: Double
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
            Spacer()
            TextField("0", value: $value, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 92)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
            Text(unit).foregroundStyle(AppTheme.muted).frame(minWidth: 38, alignment: .leading)
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
                }.fontWeight(.semibold)
            }
        }
    }
}
