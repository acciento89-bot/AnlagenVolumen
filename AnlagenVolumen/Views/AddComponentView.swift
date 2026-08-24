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
                    Picker("Bauteil", selection: $kind) {
                        Text("Rohr").tag(ComponentKind.pipe)
                        Text("FBH").tag(ComponentKind.floorHeating)
                        Text("Heizkörper").tag(ComponentKind.radiator)
                        Text("Gerät").tag(ComponentKind.other)
                    }
                    .pickerStyle(.segmented).padding()
                    Group {
                        switch kind {
                        case .pipe: PipeEntryView(project: project, kind: .pipe, onSave: finish)
                        case .floorHeating: PipeEntryView(project: project, kind: .floorHeating, onSave: finish)
                        case .radiator: RadiatorEntryView(project: project, onSave: finish)
                        default: ManualEntryView(project: project, onSave: finish)
                        }
                    }
                }
            }
            .navigationTitle("Bauteil hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Abbrechen") { dismiss() } } }
        }.tint(AppTheme.accent)
    }

    private func finish(_ project: VolumeProject) { onSave(project); dismiss() }
}
