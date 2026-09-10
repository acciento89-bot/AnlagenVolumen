import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ProjectStore
    var body: some View {
        TabView {
            InventoryView().tabItem { Label("Inventar", systemImage: "shippingbox") }
            FillAuditView().tabItem { Label("Füllabgleich", systemImage: "drop.halffull") }
        }.tint(AppTheme.accent).preferredColorScheme(.light)
            .alert("Projektdaten", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) { Button("OK") { store.error = nil } } message: { Text(store.error ?? "") }
    }
}


struct InventoryView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var showAdd = false
    @State private var showProjects = false

    private var project: VolumeProject { store.selectedProject ?? VolumeProject() }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VolumeLedgerLines()

                ScrollView {
                    VStack(alignment: .leading, spacing: 17) {
                        ledgerHeader
                        planningTotal
                        quickActions
                        componentLedger
                        methodNote
                    }
                    .padding(.horizontal, 17)
                    .padding(.vertical, 14)
                    .padding(.bottom, 34)
                }
            }
            .navigationTitle("VolumeCalc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProjects = true } label: {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(AppTheme.accent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddComponentView(project: project) { store.upsert($0) }
            }
            .sheet(isPresented: $showProjects) {
                ProjectListView()
            }
        }
        .tint(AppTheme.accent)
        .preferredColorScheme(.light)
    }

    private var ledgerHeader: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 14) {
                VolumeHeroIcon()
                VStack(alignment: .leading, spacing: 4) {
                    Text("ANLAGENINVENTAR")
                        .font(.subheadline.weight(.bold))
                        .tracking(1.8)
                        .foregroundStyle(AppTheme.accent)
                    Text(project.name)
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.ink)
                    Text("Wasserinhalt Bauteil für Bauteil erfassen")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ledgerTag("\(project.components.count) Bauteile", icon: "square.stack.3d.up")
                ledgerTag("+\(String(format: "%.1f", project.reservePercent)) % Reserve", icon: "plusminus")
            }
        }
        .padding(17)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.line))
    }

    private var planningTotal: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SUMMENBLATT")
                    .font(.subheadline.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.muted)
                Spacer()
                NavigationLink {
                    ProjectSettingsView(project: project) { store.upsert($0) }
                } label: {
                    Label("Reserve", systemImage: "slider.horizontal.3")
                        .font(.caption.weight(.bold))
                }
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PLANUNGSWERT")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(project.planningVolumeLiters, format: .number.precision(.fractionLength(1)))
                            .font(.largeTitle.bold().monospacedDigit())
                            .foregroundStyle(AppTheme.ink)
                        Text("Liter")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppTheme.muted)
                    }
                }
                Spacer()
                Image(systemName: "drop.fill")
                    .font(.system(size: 37))
                    .foregroundStyle(AppTheme.accent.opacity(0.75))
            }

            Divider().overlay(AppTheme.line)

            HStack(spacing: 10) {
                MetricCard(title: "Berechnet", value: project.calculatedVolumeLiters, emphasized: true)
                MetricCard(title: "Reserve", value: project.reserveLiters, emphasized: false)
            }
        }
        .padding(17)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.accent)
                .frame(width: 4)
                .padding(.vertical, 12)
        }
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.line))
    }

    private var quickActions: some View {
        HStack(spacing: 11) {
            Button { showAdd = true } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "plus.square.fill")
                        .font(.title2)
                    Text("Bauteil erfassen")
                        .font(.subheadline.weight(.bold))
                    Text("Rohr · Heizkörper · Speicher")
                        .font(.subheadline)
                        .opacity(0.78)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .foregroundStyle(.white)
                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain)

            ShareLink(item: exportText) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                    Text("Summen teilen")
                        .font(.subheadline.weight(.bold))
                    Text("Für Bericht oder MAG")
                        .font(.subheadline)
                        .opacity(0.78)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .foregroundStyle(AppTheme.ink)
                .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.line))
            }
        }
    }

    private var componentLedger: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BAUTEILLISTE")
                        .font(.subheadline.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.muted)
                    Text("Anlageninhalt nach Komponenten")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.ink)
                }
                Spacer()
                Text("\(project.components.count)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.accent.opacity(0.09), in: Capsule())
            }

            if project.components.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "shippingbox")
                            .font(.title2)
                            .foregroundStyle(AppTheme.accent)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Inventar ist noch leer")
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink)
                            Text("Füge zuerst eine reale wasserführende Komponente hinzu.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                    Button("Erstes Bauteil hinzufügen") { showAdd = true }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)
                }
                .padding(17)
                .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line))
            } else {
                VStack(spacing: 8) {
                    ForEach(project.components.indices, id: \.self) { index in
                        let component = project.components[index]
                        ComponentLedgerRow(index: index + 1, component: component) {
                            var copy = project
                            copy.components.removeAll { $0.id == component.id }
                            store.upsert(copy)
                        }
                    }
                }
            }
        }
    }

    private var methodNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Berechnungsgrundlage", systemImage: "info.circle")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.accent)
            Text("Rohrvolumen wird geometrisch aus dem Innendurchmesser berechnet. Rohr- und Heizkörper-Referenzen sind Arbeitshilfen für typische bzw. historische Abmessungen. Für eine exakte Auslegung haben Herstellerdaten, Typenschild und eindeutig ermittelte Wasserinhalte Vorrang.")
                .font(.caption)
                .foregroundStyle(AppTheme.muted)
        }
        .padding(15)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line))
    }

    private func ledgerTag(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.muted)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.panel, in: Capsule())
            .overlay(Capsule().stroke(AppTheme.line))
    }

    private var exportText: String {
        var lines = [
            "VolumeCalc – \(project.name)",
            "Berechnet: \(String(format: "%.1f", project.calculatedVolumeLiters)) l",
            "Planungswert (+\(String(format: "%.1f", project.reservePercent)) %): \(String(format: "%.1f", project.planningVolumeLiters)) l",
            ""
        ]
        lines += project.components.map {
            "• \($0.name): \(String(format: "%.2f", $0.totalLiters)) l"
        }
        return lines.joined(separator: "\n")
    }
}

private struct ComponentLedgerRow: View {
    let index: Int
    let component: VolumeComponent
    let delete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(.system(.caption, design: .monospaced).weight(.black))
                .foregroundStyle(AppTheme.muted)
                .frame(width: 28)

            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 32, height: 32)
                .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(component.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text(component.kind.title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                if let source = component.source {
                    Text(source)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(component.totalLiters, format: .number.precision(.fractionLength(2)))
                    .font(.system(.headline, design: .monospaced).weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text("Liter")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .padding(13)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(AppTheme.line))
        .contextMenu {
            Button(role: .destructive, action: delete) {
                Label("Löschen", systemImage: "trash")
            }
        }
    }

    private var icon: String {
        switch component.kind {
        case .pipe, .floorHeating, .wallHeating, .ceilingHeating:
            return "point.topleft.down.to.point.bottomright.curvepath"
        case .radiator:
            return "rectangle.split.3x1"
        case .buffer:
            return "cylinder.split.1x2"
        case .heatGenerator:
            return "flame.fill"
        case .hydraulicSeparator:
            return "arrow.up.arrow.down.circle"
        case .distributor:
            return "slider.horizontal.3"
        case .heatExchanger:
            return "arrow.left.arrow.right"
        case .other:
            return "drop.circle"
        }
    }
}

private struct VolumeLedgerLines: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                var y: CGFloat = 26
                while y < proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += 34
                }
            }
            .stroke(AppTheme.line.opacity(0.22), lineWidth: 0.5)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private func volumeText(_ value: Double) -> String { value.formatted(.number.precision(.fractionLength(0...2))) }

struct FillAuditView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var adding = false
    @State private var sourceDraft: VolumeComponent?
    @State private var deleting: FillCheck?
    private var project: VolumeProject { store.selectedProject ?? VolumeProject() }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("VOLUMEN NACHWEISEN", systemImage: "drop.halffull").font(.headline)
                    Text("Berechnet trifft eingefüllt.").font(.largeTitle.bold())
                    Text("Vergleiche das Bauteilinventar mit einer vollständigen Befüllung. Halte die Datengrundlage und offene Quellen für die Übergabe fest.").foregroundStyle(.secondary)
                    Text(project.name).font(.headline)
                }
                Section("Inventar nach Bauteilart") {
                    ForEach(ComponentKind.allCases.filter { project.totalLiters(for: $0) > 0 }, id: \.self) { kind in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(kind.title).font(.headline)
                            Text("\(volumeText(project.totalLiters(for: kind))) l").font(.title3.monospacedDigit())
                        }
                    }
                    LabeledContent("Berechneter Wasserinhalt", value: "\(volumeText(project.calculatedVolumeLiters)) l")
                    Text("Die Planungsreserve wird beim Füllabgleich nicht als realer Wasserinhalt mitgerechnet.").foregroundStyle(.secondary)
                }
                Section("Datengrundlage prüfen") {
                    Text("\(project.undocumentedComponents.count) von \(project.components.count) Bauteilen ohne Quellenangabe").font(.headline)
                    ForEach(project.components) { component in
                        Button { sourceDraft = component } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(component.name).font(.headline).foregroundStyle(.primary)
                                Text(component.source?.isEmpty == false ? component.source! : "Quelle ergänzen: Hersteller, Messung oder Schätzung").foregroundStyle(.secondary)
                                if let note = component.note, !note.isEmpty { Text(note).foregroundStyle(.secondary) }
                            }.padding(.vertical, 5)
                        }
                    }
                }
                Section("Vollständige Befüllungen") {
                    Button { adding = true } label: { Label("Füllabgleich erfassen", systemImage: "plus.circle.fill") }
                        .disabled(project.calculatedVolumeLiters <= 0)
                    if (project.fillChecks ?? []).isEmpty { Text("Noch kein Abgleich. Erfasse zuerst das Inventar und anschließend eine vollständige Befüllung der anfangs leeren Anlage.").foregroundStyle(.secondary) }
                    ForEach((project.fillChecks ?? []).sorted { $0.date > $1.date }) { check in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(check.date.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                            Text("\(volumeText(check.netFillL)) l eingefüllt").font(.title2.bold())
                            Text("Inventar zum Messzeitpunkt: \(volumeText(check.calculatedBaselineL)) l · \(check.componentCount) Bauteile")
                            Text("Abweichung: \(volumeText(check.deviationL)) l / \(volumeText(check.deviationPercent ?? 0)) %").font(.headline)
                            Label(check.isWithinTolerance ? "Innerhalb Projekttoleranz" : "Abweichung untersuchen", systemImage: check.isWithinTolerance ? "checkmark.circle" : "exclamationmark.triangle")
                            Text("Zähler \(volumeText(check.meterStartL)) → \(volumeText(check.meterEndL)) l; abgelassen \(volumeText(check.drainedL)) l; Toleranz ±\(volumeText(check.tolerancePercent)) %").foregroundStyle(.secondary)
                            if !check.note.isEmpty { Text(check.note) }
                            Button("Abgleich löschen", role: .destructive) { deleting = check }
                        }.padding(.vertical, 8)
                    }
                }
                Section("Übergabe") {
                    ShareLink(item: evidenceReport) { Label("Inventar- und Füllnachweis teilen", systemImage: "square.and.arrow.up") }
                    Text("Ein Abgleich gilt für eine anfangs leere Anlage innerhalb derselben Systemgrenzen. Nachfüllungen im laufenden Betrieb sind dafür ungeeignet. Abweichungen können auf Restwasser, unvollständige Entlüftung, Messunsicherheit oder fehlende Bauteile hinweisen; sie sind keine automatische Leckdiagnose.").foregroundStyle(.secondary)
                }
            }.navigationTitle("Füllabgleich")
                .sheet(isPresented: $adding) { FillCheckEditor(project: project) { check in var copy = project; copy.fillChecks = (copy.fillChecks ?? []) + [check]; return store.upsert(copy) } }
                .sheet(item: $sourceDraft) { component in ComponentSourceEditor(component: component) { changed in var copy = project; if let index = copy.components.firstIndex(where: { $0.id == changed.id }) { copy.components[index] = changed }; return store.upsert(copy) } }
                .confirmationDialog("Abgleich endgültig löschen?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
                    Button("Löschen", role: .destructive) { if let deleting { var copy = project; copy.fillChecks?.removeAll { $0.id == deleting.id }; store.upsert(copy) }; deleting = nil }
                }
        }
    }
    private var evidenceReport: String {
        var lines = ["VolumeCalc – Inventar- und Füllnachweis", project.name, Date().formatted(), "Berechnet \(volumeText(project.calculatedVolumeLiters)) l; Reserve separat \(volumeText(project.reserveLiters)) l", ""]
        for component in project.components {
            lines.append("\(component.name) [\(component.kind.title)]: \(volumeText(component.quantity)) × \(volumeText(component.unitVolumeLiters)) l = \(volumeText(component.totalLiters)) l; Quelle: \(component.source ?? "nicht dokumentiert"); \(component.note ?? "")")
        }
        for check in project.fillChecks ?? [] {
            lines.append("\nBefüllung \(check.date.formatted()): Zähler \(volumeText(check.meterStartL)) → \(volumeText(check.meterEndL)) l; abgelassen \(volumeText(check.drainedL)) l; netto \(volumeText(check.netFillL)) l. Inventar-Basis \(volumeText(check.calculatedBaselineL)) l / \(check.componentCount) Bauteile. Differenz \(volumeText(check.deviationL)) l / \(volumeText(check.deviationPercent ?? 0)) %. Projekttoleranz ±\(volumeText(check.tolerancePercent)) %. Anfangs leere Anlage bestätigt. \(check.note)")
        }
        lines.append("Die Inventar-Basis früherer Befüllungen bleibt unverändert. Projekttoleranz ist keine Normbestätigung; keine Leckdiagnose.")
        return lines.joined(separator: "\n")
    }
}

private struct FillCheckEditor: View {
    let project: VolumeProject
    let save: (FillCheck) -> Bool
    @State private var check = FillCheck()
    @State private var failed = false
    @Environment(\.dismiss) private var dismiss
    private var completed: FillCheck { var copy = check; copy.calculatedBaselineL = project.calculatedVolumeLiters; copy.componentCount = project.components.count; return copy }
    var body: some View {
        NavigationStack {
            Form {
                Section("Messung") {
                    DatePicker("Befüllung", selection: $check.date)
                    AuditNumber(title: "Zählerstand vor Befüllung", value: $check.meterStartL, unit: "l")
                    AuditNumber(title: "Zählerstand nach Befüllung", value: $check.meterEndL, unit: "l")
                    AuditNumber(title: "Währenddessen abgelassen / verworfen", value: $check.drainedL, unit: "l")
                    AuditNumber(title: "Projekttoleranz ±", value: $check.tolerancePercent, unit: "%")
                    Toggle("Anlage war anfangs leer; Inventar und Messung umfassen dieselben Anlagenteile", isOn: $check.confirmedEmptySystem)
                }
                Section("Dokumentation") {
                    Text("Inventar-Basis: \(volumeText(project.calculatedVolumeLiters)) l ohne Planungsreserve. Dieser Wert wird mit dem Abgleich gespeichert.")
                    TextField("Messgerät, Systemgrenzen, Entlüftung …", text: $check.note, axis: .vertical)
                    if completed.isValid { Text("Netto eingefüllt: \(volumeText(completed.netFillL)) l").font(.title2.bold()) }
                    else { Text("Zählerende muss über dem Start liegen; Nettofüllung > 0 und Toleranz 0–100 %. Systemgrenzen bestätigen.").foregroundStyle(.red) }
                }
            }.navigationTitle("Befüllung erfassen")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Speichern") { if save(completed) { dismiss() } else { failed = true } }.disabled(!completed.isValid) }
                }.alert("Nicht gespeichert. Speicherplatz prüfen.", isPresented: $failed) {}
        }.interactiveDismissDisabled().dismissKeyboardToolbar()
    }
}

private struct ComponentSourceEditor: View {
    @State var component: VolumeComponent
    let save: (VolumeComponent) -> Bool
    @State private var failed = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Text(component.name).font(.headline)
                TextField("Quelle / Datenblatt / Messverfahren", text: Binding(get: { component.source ?? "" }, set: { component.source = $0 }), axis: .vertical)
                TextField("Notiz / Unsicherheit / Fundstelle", text: Binding(get: { component.note ?? "" }, set: { component.note = $0 }), axis: .vertical)
                Text("Quellenangaben dokumentieren die Herkunft des Werts. Sie bestätigen nicht automatisch seine Genauigkeit.").foregroundStyle(.secondary)
            }.navigationTitle("Datengrundlage")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Speichern") { if save(component) { dismiss() } else { failed = true } } }
                }.alert("Nicht gespeichert. Speicherplatz prüfen.", isPresented: $failed) {}
        }.interactiveDismissDisabled()
    }
}

private struct AuditNumber: View {
    let title: String
    @Binding var value: Double
    let unit: String
    @State private var text: String
    init(title: String, value: Binding<Double>, unit: String) {
        self.title = title; _value = value; self.unit = unit
        _text = State(initialValue: value.wrappedValue.formatted(.number.grouping(.never)))
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            TextField(unit, text: $text).keyboardType(.decimalPad).font(.title3.monospacedDigit())
                .accessibilityLabel(title + ", " + unit)
                .onChange(of: text) { _, raw in value = Double(raw.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")) ?? .nan }
            if !value.isFinite { Text("Gültige Zahl erforderlich").foregroundStyle(.red) }
        }.padding(.vertical, 4)
    }
}
