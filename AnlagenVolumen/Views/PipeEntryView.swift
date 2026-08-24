import SwiftUI

struct PipeEntryView: View {
    let project: VolumeProject
    let kind: ComponentKind
    let onSave: (VolumeProject) -> Void
    @State private var selectedID = ReferenceData.pipePresets.first!.id
    @State private var lengthMeters = 10.0
    @State private var circuits = 1.0
    @State private var customDiameter = 12.0
    @State private var useCustom = false

    private var preset: PipePreset {
        ReferenceData.pipePresets.first(where: { $0.id == selectedID }) ?? ReferenceData.pipePresets[0]
    }

    private var diameter: Double { useCustom ? customDiameter : preset.innerDiameterMM }
    private var volume: Double {
        VolumeCalculator.pipeVolumeLiters(innerDiameterMM: diameter, lengthMeters: lengthMeters) * circuits
    }

    private var isSurfaceHeating: Bool {
        kind == .floorHeating || kind == .wallHeating || kind == .ceilingHeating
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    Toggle("Eigenen Innendurchmesser verwenden", isOn: $useCustom)
                    if useCustom {
                        NumberField(title: "Innendurchmesser", unit: "mm", value: $customDiameter)
                    } else {
                        Picker("Rohrdimension", selection: $selectedID) {
                            ForEach(ReferenceData.pipePresets) { item in
                                Text("\(item.group) · \(item.name)").tag(item.id)
                            }
                        }
                        if !preset.note.isEmpty {
                            Text(preset.note)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                    NumberField(
                        title: isSurfaceHeating ? "Rohrlänge je Kreis" : "Leitungslänge",
                        unit: "m",
                        value: $lengthMeters
                    )
                    NumberField(
                        title: isSurfaceHeating ? "Heizkreise" : "Anzahl",
                        unit: "×",
                        value: $circuits
                    )
                }

                GlassCard {
                    Text("Vorschau").font(.caption.bold()).foregroundStyle(AppTheme.muted)
                    HStack(alignment: .firstTextBaseline) {
                        Text(volume, format: .number.precision(.fractionLength(2)))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                        Text("l").foregroundStyle(AppTheme.muted)
                        Spacer()
                        Text("Ø innen \(diameter, format: .number.precision(.fractionLength(1))) mm")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                    }
                    Text("\(volume / max(circuits, 1), format: .number.precision(.fractionLength(3))) l je Strang/Kreis")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                }

                Button("Hinzufügen") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .disabled(lengthMeters <= 0 || circuits <= 0 || diameter <= 0)
            }
            .padding(18)
        }
        .dismissKeyboardToolbar()
    }

    private func save() {
        let effective = useCustom
            ? PipePreset(
                group: "Benutzerdefiniert",
                name: "Ø innen \(VolumeCalculator.format(customDiameter)) mm",
                innerDiameterMM: customDiameter,
                note: "Manuell eingegebener Innendurchmesser"
            )
            : preset
        let component = VolumeCalculator.componentForPipe(
            preset: effective,
            lengthMeters: lengthMeters,
            circuits: circuits,
            kind: kind
        )
        var copy = project
        copy.components.append(component)
        onSave(copy)
    }
}
