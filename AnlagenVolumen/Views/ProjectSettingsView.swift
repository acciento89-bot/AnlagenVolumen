import SwiftUI

struct ProjectSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var edited: VolumeProject
    let onSave: (VolumeProject) -> Void

    init(project: VolumeProject, onSave: @escaping (VolumeProject) -> Void) {
        _edited = State(initialValue: project); self.onSave = onSave
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        TextField("Projektname", text: $edited.name)
                            .padding(10).background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        NumberField(title: "Planungsreserve", unit: "%", value: $edited.reservePercent)
                    }
                    GlassCard {
                        Text("Die Reserve verändert nicht den berechneten realen Anlageninhalt. Sie wird separat als Planungswert ausgewiesen.")
                            .font(.footnote).foregroundStyle(AppTheme.muted)
                    }
                }.padding(18)
            }
        }
        .navigationTitle("Projekt")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Speichern") { onSave(edited); dismiss() }.fontWeight(.semibold) } }
        .dismissKeyboardToolbar()
    }
}
