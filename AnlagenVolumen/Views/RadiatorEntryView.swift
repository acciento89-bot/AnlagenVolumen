import SwiftUI

struct RadiatorEntryView: View {
    private enum RadiatorMode: String, CaseIterable, Identifiable {
        case panel
        case steelSection
        case castSection
        case manual

        var id: String { rawValue }

        var title: String {
            switch self {
            case .panel: return "Plattenheizkörper"
            case .steelSection: return "Stahl-Gliederheizkörper"
            case .castSection: return "Guss-Gliederheizkörper"
            case .manual: return "Herstellerwert / Manuell"
            }
        }
    }

    let project: VolumeProject
    let onSave: (VolumeProject) -> Void

    @State private var mode: RadiatorMode = .panel
    @State private var type = "22"
    @State private var height = 600
    @State private var lengthMM = 1000.0
    @State private var quantity = 1.0

    @State private var sections = 10.0
    @State private var sectionReferenceID = ReferenceData.sectionRadiatorReferences.first(where: { $0.material == .steel })!.id

    @State private var manualName = "Heizkörper (Herstellerwert)"
    @State private var manualEach = 6.6

    private var availableTypes: [String] {
        Array(Set(ReferenceData.radiatorReferences.map(\.type))).sorted()
    }

    private var heights: [Int] {
        ReferenceData.radiatorReferences
            .filter { $0.type == type }
            .map(\.heightMM)
            .sorted()
    }

    private var panelReference: RadiatorReference? {
        ReferenceData.radiatorReference(type: type, heightMM: height)
    }

    private var sectionMaterial: SectionRadiatorReference.Material? {
        switch mode {
        case .steelSection: return .steel
        case .castSection: return .castIron
        default: return nil
        }
    }

    private var sectionReferences: [SectionRadiatorReference] {
        guard let sectionMaterial else { return [] }
        return ReferenceData.sectionRadiators(material: sectionMaterial)
    }

    private var sectionReference: SectionRadiatorReference? {
        sectionReferences.first(where: { $0.id == sectionReferenceID }) ?? sectionReferences.first
    }

    private var total: Double {
        switch mode {
        case .panel:
            guard let panelReference else { return 0 }
            return VolumeCalculator.radiatorVolumeLiters(
                litersPerMeter: panelReference.litersPerMeter,
                lengthMM: lengthMM,
                quantity: quantity
            )
        case .steelSection, .castSection:
            guard let sectionReference else { return 0 }
            return VolumeCalculator.sectionRadiatorVolumeLiters(
                litersPerSection: sectionReference.litersPerSection,
                sections: sections,
                quantity: quantity
            )
        case .manual:
            return max(0, manualEach) * max(0, quantity)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    Picker("Heizkörper-Bauart", selection: $mode) {
                        ForEach(RadiatorMode.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: mode) { _, newMode in
                        if newMode == .steelSection {
                            sectionReferenceID = ReferenceData.sectionRadiators(material: .steel).first?.id ?? sectionReferenceID
                        } else if newMode == .castSection {
                            sectionReferenceID = ReferenceData.sectionRadiators(material: .castIron).first?.id ?? sectionReferenceID
                        }
                    }

                    switch mode {
                    case .panel:
                        panelFields
                    case .steelSection, .castSection:
                        sectionFields
                    case .manual:
                        manualFields
                    }

                    NumberField(title: "Anzahl Heizkörper", unit: "×", value: $quantity)
                }

                GlassCard {
                    Text("Gesamt").font(.caption.bold()).foregroundStyle(AppTheme.muted)
                    HStack(alignment: .firstTextBaseline) {
                        Text(total, format: .number.precision(.fractionLength(2)))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                        Text("l").foregroundStyle(AppTheme.muted)
                    }

                    switch mode {
                    case .panel:
                        Text("Purmo-Referenzwerte sind baureihenspezifisch. Herstellerdaten haben Vorrang.")
                            .font(.footnote).foregroundStyle(AppTheme.muted)
                    case .steelSection, .castSection:
                        Text("Bestands-/Normreferenz je Glied. Bei bekannter Baureihe immer den Hersteller-Wasserinhalt verwenden.")
                            .font(.footnote).foregroundStyle(AppTheme.muted)
                    case .manual:
                        Text("Direkter Wasserinhalt je Heizkörper aus Herstellerangabe, Typenschild oder eigener Ermittlung.")
                            .font(.footnote).foregroundStyle(AppTheme.muted)
                    }
                }

                Button("Hinzufügen") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundStyle(.black)
                    .disabled(total <= 0)
            }
            .padding(18)
        }
        .dismissKeyboardToolbar()
    }

    @ViewBuilder
    private var panelFields: some View {
        Picker("Typ", selection: $type) {
            ForEach(availableTypes, id: \.self) { Text("Typ \($0)").tag($0) }
        }
        .onChange(of: type) { _, _ in
            if !heights.contains(height) { height = heights.first ?? 600 }
        }

        Picker("Bauhöhe", selection: $height) {
            ForEach(heights, id: \.self) { Text("\($0) mm").tag($0) }
        }
        NumberField(title: "Baulänge", unit: "mm", value: $lengthMM)
        if let panelReference {
            Text("Referenz: \(panelReference.litersPerMeter, format: .number.precision(.fractionLength(1))) l je lfd. m")
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
        }
    }

    @ViewBuilder
    private var sectionFields: some View {
        Picker("Abmessung", selection: $sectionReferenceID) {
            ForEach(sectionReferences) { item in
                Text("\(item.displayName) · \(item.litersPerSection, format: .number.precision(.fractionLength(3))) l/Glied")
                    .tag(item.id)
            }
        }
        NumberField(title: "Glieder je Heizkörper", unit: "×", value: $sections)
        if let sectionReference {
            Text("\(sectionReference.litersPerSection, format: .number.precision(.fractionLength(3))) l je Glied · \(sectionReference.dataset)")
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
        }
    }

    @ViewBuilder
    private var manualFields: some View {
        TextField("Bezeichnung", text: $manualName)
            .padding(10)
            .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
        NumberField(title: "Wasserinhalt je Heizkörper", unit: "l", value: $manualEach)
    }

    private func save() {
        var copy = project
        switch mode {
        case .panel:
            if let panelReference {
                copy.components.append(
                    VolumeCalculator.componentForRadiator(
                        reference: panelReference,
                        lengthMM: lengthMM,
                        quantity: quantity
                    )
                )
            }
        case .steelSection, .castSection:
            if let sectionReference {
                copy.components.append(
                    VolumeCalculator.componentForSectionRadiator(
                        reference: sectionReference,
                        sections: sections,
                        quantity: quantity
                    )
                )
            }
        case .manual:
            copy.components.append(
                VolumeComponent(
                    kind: .radiator,
                    name: manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Heizkörper (Herstellerwert)" : manualName,
                    quantity: quantity,
                    unitVolumeLiters: manualEach,
                    source: "Manuelle Hersteller-/Messangabe"
                )
            )
        }
        onSave(copy)
    }
}
