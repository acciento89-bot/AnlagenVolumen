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
                        .font(.caption2.weight(.black))
                        .tracking(1.8)
                        .foregroundStyle(AppTheme.accent)
                    Text(project.name)
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Text("Wasserinhalt Bauteil für Bauteil erfassen")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ledgerTag("\(project.components.count) Bauteile", icon: "square.stack.3d.up")
                ledgerTag("+\(project.reservePercent, format: .number.precision(.fractionLength(0...1))) % Reserve", icon: "plusminus")
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
                    .font(.caption2.weight(.black))
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
                        .font(.caption2.weight(.black))
                        .foregroundStyle(AppTheme.accent)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(project.planningVolumeLiters, format: .number.precision(.fractionLength(1)))
                            .font(.system(size: 46, weight: .bold, design: .monospaced))
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
                        .font(.caption2)
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
                        .font(.caption2)
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
                        .font(.caption2.weight(.black))
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
                    ForEach(Array(project.components.enumerated()), id: \.element.id) { index, component in
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
                    .font(.caption2)
                    .foregroundStyle(AppTheme.muted)
                if let source = component.source {
                    Text(source)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.muted.opacity(0.85))
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(component.totalLiters, format: .number.precision(.fractionLength(2)))
                    .font(.system(.headline, design: .monospaced).weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text("Liter")
                    .font(.caption2.weight(.semibold))
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
