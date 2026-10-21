import SwiftUI

struct DesignAlternativesView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var editing: VolumeAlternative?
    @State private var deleting: UUID?
    @State private var projects = false

    var body: some View {
        NavigationStack {
            List {
                if let project = store.selectedProject {
                    Section {
                        Text(project.name).font(.title2.bold()).foregroundStyle(AppTheme.accent)
                        Text("Plane einen anderen Aufbau, ohne deinen tatsächlichen Bestand oder Füllprüfungen zu verändern.")
                        Button { editing = VolumeAlternative(project: project, name: String(localized: "Neue Variante")) } label: {
                            Label("Variante anlegen", systemImage: "plus.square.on.square")
                        }
                    }
                    Section("Gespeicherte Varianten") {
                        if (project.alternatives ?? []).isEmpty { Text("Noch keine Variante angelegt.").foregroundStyle(AppTheme.muted) }
                        ForEach(project.alternatives ?? []) { alternative in
                            Button { editing = alternative } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(alternative.name).font(.headline).foregroundStyle(AppTheme.ink)
                                    Text(alternative.capturedAt, style: .date).font(.caption).foregroundStyle(AppTheme.muted)
                                    if let result = try? alternative.comparison() {
                                        Text("\(result.baselineWaterLiters.formatted(.number.precision(.fractionLength(1)))) l → \(result.proposedWaterLiters.formatted(.number.precision(.fractionLength(1)))) l")
                                            .font(.subheadline.monospacedDigit()).foregroundStyle(AppTheme.accent)
                                    }
                                    if alternative.isBaselineStale(comparedWith: project) {
                                        Label("Bestand inzwischen geändert", systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.orange)
                                    }
                                }.padding(.vertical, 5)
                            }
                            .swipeActions { Button("Löschen", role: .destructive) { deleting = alternative.id } }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden).background(AppTheme.background)
            .navigationTitle("Variantenvergleich")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button { projects = true } label: { Image(systemName: "folder") }.accessibilityLabel("Projekte") } }
            .sheet(isPresented: $projects) { ProjectListView() }
            .sheet(item: $editing) { alternative in
                AlternativeEditor(alternative: alternative) { changed in
                    guard var current = store.projects.first(where: { $0.id == changed.baselineProjectID }) else { return false }
                    var alternatives = current.alternatives ?? []
                    if let index = alternatives.firstIndex(where: { $0.id == changed.id }) { alternatives[index] = changed }
                    else { alternatives.append(changed) }
                    current.alternatives = alternatives
                    return store.upsert(current)
                }
            }
            .alert("Variante löschen?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
                Button("Abbrechen", role: .cancel) { deleting = nil }
                Button("Löschen", role: .destructive) {
                    guard let id = deleting, var current = store.selectedProject else { return }
                    current.alternatives = (current.alternatives ?? []).filter { $0.id != id }
                    _ = store.upsert(current); deleting = nil
                }
            } message: { Text("Nur diese Planungsvariante wird entfernt. Dein tatsächlicher Bestand und Füllprüfungen bleiben erhalten.") }
        }.tint(AppTheme.accent)
    }
}

private struct AlternativeEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @EnvironmentObject private var store: ProjectStore
    @State private var draft: VolumeAlternative
    @State private var reserveInput: String
    @State private var adding = false
    @State private var component: VolumeComponent?
    @State private var saveFailed = false
    let onSave: (VolumeAlternative) -> Bool

    init(alternative: VolumeAlternative, onSave: @escaping (VolumeAlternative) -> Bool) {
        _draft = State(initialValue: alternative); _reserveInput = State(initialValue: String(alternative.proposedReservePercent)); self.onSave = onSave
    }
    private var editedDraft: VolumeAlternative {
        var value = draft
        value.proposedReservePercent = VolumeAlternative.parseDraftNumber(reserveInput) ?? .nan
        return value
    }
    private var actual: VolumeProject? { store.projects.first { $0.id == draft.baselineProjectID } }
    private var proposedProject: VolumeProject {
        VolumeProject(name: draft.name, reservePercent: draft.proposedReservePercent, components: draft.proposedComponents)
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("Planungsvariante") {
                    TextField("Name", text: $draft.name).accessibilityIdentifier("alternative-name")
                    LabeledContent("Bestandsaufnahme", value: draft.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    Text(draft.baselineProjectName).foregroundStyle(AppTheme.muted)
                    if let actual, draft.isBaselineStale(comparedWith: actual) {
                        Label("Der aktuelle Bestand wurde nach der Aufnahme geändert. Dieser Vergleich verwendet weiterhin den eingefrorenen Bestand.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }
                if let comparison = try? editedDraft.comparison() {
                    Section("Bestand → Variante") {
                        comparisonRow("Berechneter Wasserinhalt", before: comparison.baselineWaterLiters, after: comparison.proposedWaterLiters)
                        comparisonRow("Reserve", before: comparison.baselineReserveLiters, after: comparison.proposedReserveLiters)
                        comparisonRow("Planungsvolumen", before: comparison.baselinePlanningLiters, after: comparison.proposedPlanningLiters)
                    }
                }
                Section("Aufbau der Variante") {
                    AlternativeNumberField(title: "Planungsreserve", unit: "%", text: $reserveInput)
                    ForEach(draft.proposedComponents) { item in
                        Button { component = item } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).foregroundStyle(AppTheme.ink)
                                    Text("\(item.totalLiters.formatted(.number.precision(.fractionLength(1)))) l").foregroundStyle(AppTheme.accent)
                                }
                                Spacer(); Image(systemName: "pencil")
                            }
                        }
                        .swipeActions { Button("Entfernen", role: .destructive) { draft.proposedComponents.removeAll { $0.id == item.id } } }
                    }
                    Button { adding = true } label: { Label("Bauteil hinzufügen", systemImage: "plus") }
                }
                Section {
                    if let report = try? editedDraft.report(locale: locale) {
                        ShareLink(item: report) { Label("Vergleich teilen", systemImage: "square.and.arrow.up") }
                    }
                    Text("Die Reserve ist ein separater Planungswert. Die Variante ist keine Messung und kein Nachweis eines tatsächlichen Umbaus.").font(.footnote).foregroundStyle(AppTheme.muted)
                    if !editedDraft.isValid { Text("Bitte einen Namen sowie endliche, nicht negative Mengen, Volumen und Reserve eingeben.").foregroundStyle(.red) }
                    if saveFailed { Text("Nicht gespeichert. Die bisherigen Projektdaten bleiben erhalten.").foregroundStyle(.red) }
                }
            }
            .scrollContentBackground(.hidden).background(AppTheme.background)
            .navigationTitle("Variante").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern") { if onSave(editedDraft) { dismiss() } else { saveFailed = true } }.disabled(!editedDraft.isValid || actual == nil) }
            }
            .sheet(isPresented: $adding) {
                AddComponentView(project: proposedProject) { proposed in draft.proposedComponents = proposed.components }
            }
            .sheet(item: $component) { selected in
                AlternativeComponentEditor(component: selected) { changed in
                    if let index = draft.proposedComponents.firstIndex(where: { $0.id == changed.id }) { draft.proposedComponents[index] = changed }
                }
            }
            .dismissKeyboardToolbar()
        }.tint(AppTheme.accent)
    }
    private func comparisonRow(_ title: LocalizedStringKey, before: Double, after: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).foregroundStyle(AppTheme.muted)
            Text("\(before.formatted(.number.precision(.fractionLength(1)))) l → \(after.formatted(.number.precision(.fractionLength(1)))) l")
                .font(.headline.monospacedDigit()).foregroundStyle(AppTheme.ink)
            Text("\((after-before).formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))) l")
                .font(.subheadline.monospacedDigit()).foregroundStyle(AppTheme.accent)
        }.padding(.vertical, 5)
    }
}

private struct AlternativeComponentEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: VolumeComponent
    @State private var quantityInput: String
    @State private var unitInput: String
    let onSave: (VolumeComponent) -> Void
    init(component: VolumeComponent, onSave: @escaping (VolumeComponent) -> Void) {
        _draft = State(initialValue: component); _quantityInput = State(initialValue: String(component.quantity)); _unitInput = State(initialValue: String(component.unitVolumeLiters)); self.onSave = onSave
    }
    private var edited: VolumeComponent {
        var value = draft
        value.quantity = VolumeAlternative.parseDraftNumber(quantityInput) ?? .nan
        value.unitVolumeLiters = VolumeAlternative.parseDraftNumber(unitInput) ?? .nan
        return value
    }
    private var valid: Bool {
        edited.quantity.isFinite && edited.quantity >= 0 && edited.unitVolumeLiters.isFinite && edited.unitVolumeLiters >= 0 && edited.totalLiters.isFinite
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField("Bezeichnung", text: $draft.name)
                AlternativeNumberField(title: "Menge", unit: "", text: $quantityInput)
                AlternativeNumberField(title: "Volumen je Einheit", unit: "l", text: $unitInput)
                TextField("Quelle / Herstellerangabe", text: Binding(get: { draft.source ?? "" }, set: { draft.source = $0 }))
                TextField("Notiz", text: Binding(get: { draft.note ?? "" }, set: { draft.note = $0 }))
                Text("Prüfe bei geänderten Bauteilen auch die Quelle. Berechnete Werte aus dem Bestand werden nicht automatisch neu dimensioniert.").font(.footnote)
            }
            .navigationTitle("Bauteil der Variante").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Übernehmen") { onSave(edited); dismiss() }.disabled(!valid) }
            }.dismissKeyboardToolbar()
        }.tint(AppTheme.accent)
    }
}

private struct AlternativeNumberField: View {
    let title: String
    let unit: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(title)).foregroundStyle(AppTheme.ink)
            HStack {
                TextField("0", text: $text).keyboardType(.decimalPad)
                    .font(.title3.monospacedDigit()).padding(10)
                    .accessibilityLabel(title + ", " + unit)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(VolumeAlternative.parseDraftNumber(text) == nil ? Color.red : AppTheme.line))
                Text(unit).foregroundStyle(AppTheme.muted)
            }
        }
    }
}
