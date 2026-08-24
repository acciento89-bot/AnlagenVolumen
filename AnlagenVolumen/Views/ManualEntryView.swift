import SwiftUI

struct ManualEntryView: View {
    let project: VolumeProject
    let onSave: (VolumeProject) -> Void
    @State private var name = "Pufferspeicher"
    @State private var liters = 100.0
    @State private var quantity = 1.0
    @State private var kind: ComponentKind = .buffer

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    Picker("Kategorie", selection: $kind) {
                        Text("Puffer / Speicher").tag(ComponentKind.buffer)
                        Text("Wärmeerzeuger / Kessel / WP").tag(ComponentKind.heatGenerator)
                        Text("Hydraulische Weiche").tag(ComponentKind.hydraulicSeparator)
                        Text("Verteiler / Sammler").tag(ComponentKind.distributor)
                        Text("Wärmetauscher").tag(ComponentKind.heatExchanger)
                        Text("Sonstiges wasserführendes Bauteil").tag(ComponentKind.other)
                    }
                    .onChange(of: kind) { _, newKind in
                        name = defaultName(for: newKind)
                    }

                    TextField("Bezeichnung", text: $name)
                        .padding(10)
                        .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                    NumberField(title: "Wasserinhalt je Stück", unit: "l", value: $liters)
                    NumberField(title: "Anzahl", unit: "×", value: $quantity)

                    Text("Herstellerangabe, Typenschild, Datenblatt oder gemessenen/ermittelten Wasserinhalt verwenden.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                }

                GlassCard {
                    Text("Gesamt").font(.caption.bold()).foregroundStyle(AppTheme.muted)
                    HStack(alignment: .firstTextBaseline) {
                        Text(liters * quantity, format: .number.precision(.fractionLength(2)))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                        Text("l").foregroundStyle(AppTheme.muted)
                    }
                }

                Button("Hinzufügen") { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundStyle(.black)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || liters <= 0 || quantity <= 0)
            }
            .padding(18)
        }
        .dismissKeyboardToolbar()
    }

    private func defaultName(for kind: ComponentKind) -> String {
        switch kind {
        case .buffer: return "Pufferspeicher"
        case .heatGenerator: return "Wärmeerzeuger"
        case .hydraulicSeparator: return "Hydraulische Weiche"
        case .distributor: return "Verteiler / Sammler"
        case .heatExchanger: return "Wärmetauscher"
        default: return "Wasserführendes Bauteil"
        }
    }

    private func save() {
        var copy = project
        copy.components.append(
            VolumeComponent(
                kind: kind,
                name: name,
                quantity: quantity,
                unitVolumeLiters: liters,
                source: "Manuelle Hersteller-/Messangabe"
            )
        )
        onSave(copy)
    }
}
