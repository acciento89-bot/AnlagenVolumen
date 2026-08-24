import SwiftUI

struct RadiatorEntryView: View {
    let project: VolumeProject
    let onSave: (VolumeProject) -> Void
    @State private var type = "22"
    @State private var height = 600
    @State private var lengthMM = 1000.0
    @State private var quantity = 1.0
    @State private var manualEach = 6.6
    @State private var manualMode = false

    private var availableTypes: [String] { Array(Set(ReferenceData.radiatorReferences.map(\.type))).sorted() }
    private var heights: [Int] { ReferenceData.radiatorReferences.filter { $0.type == type }.map(\.heightMM).sorted() }
    private var reference: RadiatorReference? { ReferenceData.radiatorReference(type: type, heightMM: height) }
    private var total: Double {
        if manualMode { return manualEach * quantity }
        guard let reference else { return 0 }
        return VolumeCalculator.radiatorVolumeLiters(litersPerMeter: reference.litersPerMeter, lengthMM: lengthMM, quantity: quantity)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    Toggle("Herstellerwert direkt eingeben", isOn: $manualMode)
                    if manualMode {
                        NumberField(title: "Wasserinhalt je HK", unit: "l", value: $manualEach)
                    } else {
                        Picker("Typ", selection: $type) { ForEach(availableTypes, id: \.self) { Text("Typ \($0)").tag($0) } }
                            .onChange(of: type) { _, _ in if !heights.contains(height) { height = heights.first ?? 600 } }
                        Picker("Bauhöhe", selection: $height) { ForEach(heights, id: \.self) { Text("\($0) mm").tag($0) } }
                        NumberField(title: "Baulänge", unit: "mm", value: $lengthMM)
                        if let reference { Text("Referenz: \(reference.litersPerMeter, format: .number.precision(.fractionLength(1))) l je lfd. m").font(.caption).foregroundStyle(AppTheme.muted) }
                    }
                    NumberField(title: "Anzahl", unit: "×", value: $quantity)
                }
                GlassCard {
                    Text("Gesamt").font(.caption.bold()).foregroundStyle(AppTheme.muted)
                    HStack(alignment: .firstTextBaseline) {
                        Text(total, format: .number.precision(.fractionLength(2))).font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(AppTheme.accent)
                        Text("l").foregroundStyle(AppTheme.muted)
                    }
                    if !manualMode { Text("Referenzwerte sind hersteller-/baureihenspezifisch. Exakten Wert am Heizkörper bzw. Herstellerdatenblatt prüfen.").font(.footnote).foregroundStyle(AppTheme.muted) }
                }
                Button("Hinzufügen") { save() }
                    .buttonStyle(.borderedProminent).tint(AppTheme.accent).foregroundStyle(.black)
                    .disabled(total <= 0)
            }.padding(18)
        }.dismissKeyboardToolbar()
    }

    private func save() {
        var copy = project
        if manualMode {
            copy.components.append(VolumeComponent(kind: .radiator, name: "Heizkörper (Herstellerwert)", quantity: quantity, unitVolumeLiters: manualEach, source: "Manuelle Herstellerangabe"))
        } else if let reference {
            copy.components.append(VolumeCalculator.componentForRadiator(reference: reference, lengthMM: lengthMM, quantity: quantity))
        }
        onSave(copy)
    }
}
