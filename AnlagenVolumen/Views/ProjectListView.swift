import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.projects) { project in
                    Button {
                        store.selectedProjectID = project.id; dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack { Text(project.name).font(.headline); Spacer(); Text(project.calculatedVolumeLiters, format: .number.precision(.fractionLength(1))).bold(); Text("l") }
                            Text("\(project.components.count) Bauteile").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions { Button(role: .destructive) { store.deleteProject(project) } label: { Label("Löschen", systemImage: "trash") } }
                }
            }
            .navigationTitle("Projekte")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Fertig") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button { showNew = true } label: { Image(systemName: "plus") } }
            }
            .alert("Neues Projekt", isPresented: $showNew) {
                TextField("Projektname", text: $newName)
                Button("Erstellen") { store.createProject(name: newName.isEmpty ? "Neue Anlage" : newName); newName = "" }
                Button("Abbrechen", role: .cancel) { }
            }
        }
    }
}
