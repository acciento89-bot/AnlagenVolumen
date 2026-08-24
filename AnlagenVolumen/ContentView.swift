import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ProjectStore
    @State private var showAdd = false
    @State private var showProjects = false

    private var project: VolumeProject { store.selectedProject ?? VolumeProject() }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        totals
                        componentSection
                        magCalcSection
                        methodNote
                    }
                    .padding(18).padding(.bottom, 36)
                }
            }
            .navigationTitle("VolumeCalc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProjects = true } label: { Image(systemName: "folder") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showAdd) { AddComponentView(project: project) { store.upsert($0) } }
            .sheet(isPresented: $showProjects) { ProjectListView() }
        }
        .tint(AppTheme.accent)
    }

    private var header: some View {
        HStack(spacing: 15) {
            VolumeHeroIcon()
            VStack(alignment: .leading, spacing: 5) {
                Text(project.name).font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Anlageninhalt aus realen Bauteilen statt Bauchgefühl.")
                    .font(.subheadline).foregroundStyle(AppTheme.muted)
            }
            Spacer()
        }
    }

    private var totals: some View {
        GlassCard {
            Text("ERGEBNIS").font(.caption.bold()).tracking(1.2).foregroundStyle(AppTheme.muted)
            HStack(spacing: 10) {
                MetricCard(title: "Berechnet", value: project.calculatedVolumeLiters, emphasized: true)
                MetricCard(title: "+ Reserve", value: project.reserveLiters, emphasized: false)
            }
            HStack {
                Text("Planungswert mit \(project.reservePercent, format: .number.precision(.fractionLength(0...1))) % Reserve")
                    .font(.footnote).foregroundStyle(AppTheme.muted)
                Spacer()
                Text(project.planningVolumeLiters, format: .number.precision(.fractionLength(1)))
                    .font(.headline.bold())
                Text("l").foregroundStyle(AppTheme.muted)
            }
            NavigationLink("Reserve ändern") { ProjectSettingsView(project: project) { store.upsert($0) } }
                .font(.footnote.bold())
        }
    }

    private var componentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Bauteile").font(.title3.bold())
                Spacer()
                Text("\(project.components.count)").foregroundStyle(AppTheme.muted)
            }
            if project.components.isEmpty {
                GlassCard {
                    Image(systemName: "plus.square.dashed").font(.title2).foregroundStyle(AppTheme.accent)
                    Text("Noch keine Bauteile").font(.headline)
                    Text("Rohrleitungen, Fußbodenheizung, Heizkörper, Puffer, Wärmeerzeuger oder beliebige bekannte Wasserinhalte hinzufügen.")
                        .font(.subheadline).foregroundStyle(AppTheme.muted)
                    Button("Erstes Bauteil hinzufügen") { showAdd = true }
                        .buttonStyle(.borderedProminent).tint(AppTheme.accent).foregroundStyle(.black)
                }
            } else {
                ForEach(project.components) { component in
                    ComponentRow(component: component) {
                        var copy = project
                        copy.components.removeAll { $0.id == component.id }
                        store.upsert(copy)
                    }
                }
            }
        }
    }

    private var magCalcSection: some View {
        GlassCard {
            HStack {
                Image(systemName: "arrow.up.right.square.fill").foregroundStyle(AppTheme.accent)
                Text("Weiterverwenden").font(.headline)
            }
            Text("Den berechneten Anlageninhalt kannst du teilen oder als Eingabewert für die MAG-Auslegung verwenden.")
                .font(.subheadline).foregroundStyle(AppTheme.muted)
            ShareLink(item: exportText) {
                Label("Ergebnis teilen", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .foregroundStyle(.black)
        }
    }

    private var methodNote: some View {
        GlassCard {
            Label("Fachlicher Hinweis", systemImage: "info.circle.fill").foregroundStyle(AppTheme.accent)
            Text("Rohrvolumen wird geometrisch aus dem Innendurchmesser berechnet. Heizkörper-Referenzwerte sind baureihenspezifisch; für eine exakte Hersteller-Auslegung immer den tatsächlichen Wasserinhalt aus den technischen Unterlagen verwenden.")
                .font(.footnote).foregroundStyle(AppTheme.muted)
        }
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

private struct ComponentRow: View {
    let component: VolumeComponent
    let delete: () -> Void
    var body: some View {
        GlassCard {
            HStack(alignment: .top) {
                Image(systemName: icon).foregroundStyle(AppTheme.accent).frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(component.name).font(.headline)
                    Text(component.kind.title).font(.caption).foregroundStyle(AppTheme.muted)
                    if let source = component.source { Text(source).font(.caption2).foregroundStyle(AppTheme.muted) }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(component.totalLiters, format: .number.precision(.fractionLength(2))).font(.headline.bold())
                    Text("Liter").font(.caption).foregroundStyle(AppTheme.muted)
                }
            }
        }
        .contextMenu { Button(role: .destructive, action: delete) { Label("Löschen", systemImage: "trash") } }
    }

    private var icon: String {
        switch component.kind {
        case .pipe, .floorHeating: return "point.topleft.down.to.point.bottomright.curvepath"
        case .radiator: return "rectangle.split.3x1"
        case .buffer: return "cylinder.split.1x2"
        case .heatGenerator: return "flame.fill"
        case .hydraulicSeparator: return "arrow.up.arrow.down.circle"
        case .other: return "drop.circle"
        }
    }
}
