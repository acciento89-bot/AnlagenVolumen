import SwiftUI

struct AddComponentView: View {
    @Environment(\.dismiss) private var dismiss
    let project: VolumeProject
    let onSave: (VolumeProject) -> Void
    @State private var kind: ComponentKind = .pipe

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text("Kategorie")
                            .font(.caption.bold())
                            .foregroundStyle(AppTheme.muted)
                        Spacer()
                        Picker("Bauteil", selection: $kind) {
                            Text("Rohrleitung").tag(ComponentKind.pipe)
                            Text("Fußbodenheizung").tag(ComponentKind.floorHeating)
                            Text("Wandheizung").tag(ComponentKind.wallHeating)
                            Text("Deckenheizung").tag(ComponentKind.ceilingHeating)
                            Text("Heizkörper").tag(ComponentKind.radiator)
                            Text("Anlagenkomponente").tag(ComponentKind.other)
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)

                    Group {
                        switch kind {
                        case .pipe:
                            PipeEntryView(project: project, kind: .pipe, onSave: finish)
                        case .floorHeating:
                            PipeEntryView(project: project, kind: .floorHeating, onSave: finish)
                        case .wallHeating:
                            PipeEntryView(project: project, kind: .wallHeating, onSave: finish)
                        case .ceilingHeating:
                            PipeEntryView(project: project, kind: .ceilingHeating, onSave: finish)
                        case .radiator:
                            RadiatorEntryView(project: project, onSave: finish)
                        default:
                            ManualEntryView(project: project, onSave: finish)
                        }
                    }
                }
            }
            .navigationTitle("Bauteil hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Abbrechen") { dismiss() } } }
        }
        .tint(AppTheme.accent)
    }

    private func finish(_ project: VolumeProject) {
        onSave(project)
        dismiss()
    }
}
