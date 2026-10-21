import Foundation

/// A planning scenario owns value snapshots; it never writes back to the actual inventory.
public struct VolumeAlternative: Identifiable, Codable, Equatable, Sendable {
    /// Text-backed editing must not silently reuse an old number when a field is cleared.
    public static func parseDraftNumber(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value.isFinite, value >= 0 else { return nil }
        return value
    }

    public var id: UUID = UUID()
    public var name: String
    public let capturedAt: Date
    public let baselineProjectID: UUID
    public let baselineProjectName: String
    public let baselineReservePercent: Double
    public let baselineComponents: [VolumeComponent]
    public var proposedReservePercent: Double
    public var proposedComponents: [VolumeComponent]

    public init(project: VolumeProject, name: String, capturedAt: Date = .now) {
        self.name = name
        self.capturedAt = capturedAt
        baselineProjectID = project.id
        baselineProjectName = project.name
        baselineReservePercent = project.reservePercent
        baselineComponents = project.components
        proposedReservePercent = project.reservePercent
        proposedComponents = project.components
    }

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count <= 120 &&
        capturedAt.timeIntervalSince1970.isFinite &&
        Self.valid(components: baselineComponents, reserve: baselineReservePercent) &&
        Self.valid(components: proposedComponents, reserve: proposedReservePercent)
    }

    private static func valid(components: [VolumeComponent], reserve: Double) -> Bool {
        guard components.count <= 2_000, Set(components.map(\.id)).count == components.count,
              reserve.isFinite, reserve >= 0,
              components.allSatisfy({ $0.quantity.isFinite && $0.quantity >= 0 &&
                  $0.unitVolumeLiters.isFinite && $0.unitVolumeLiters >= 0 && $0.totalLiters.isFinite }) else { return false }
        let water = components.reduce(0) { $0 + $1.totalLiters }
        let allowance = water * reserve / 100
        return water.isFinite && allowance.isFinite && (water + allowance).isFinite
    }

    public func isBaselineStale(comparedWith project: VolumeProject) -> Bool {
        guard project.id == baselineProjectID, project.reservePercent == baselineReservePercent,
              project.components.count == baselineComponents.count,
              Set(project.components.map(\.id)).count == project.components.count else { return true }
        let current = Dictionary(uniqueKeysWithValues: project.components.map { ($0.id, $0) })
        return baselineComponents.contains { current[$0.id] != $0 }
    }

    public func comparison() throws -> VolumeAlternativeComparison {
        guard isValid else { throw VolumeAlternativeError.invalidSnapshot }
        let old = Dictionary(uniqueKeysWithValues: baselineComponents.map { ($0.id, $0) })
        let new = Dictionary(uniqueKeysWithValues: proposedComponents.map { ($0.id, $0) })
        var changes = baselineComponents.compactMap { component -> VolumeComponentChange? in
            guard let replacement = new[component.id] else {
                return VolumeComponentChange(kind: .removed, componentID: component.id, before: component, after: nil)
            }
            return replacement == component ? nil : VolumeComponentChange(kind: .changed, componentID: component.id, before: component, after: replacement)
        }
        changes += proposedComponents.filter { old[$0.id] == nil }.map {
            VolumeComponentChange(kind: .added, componentID: $0.id, before: nil, after: $0)
        }
        return VolumeAlternativeComparison(
            baselineWaterLiters: baselineComponents.reduce(0) { $0 + $1.totalLiters },
            proposedWaterLiters: proposedComponents.reduce(0) { $0 + $1.totalLiters },
            baselineReservePercent: baselineReservePercent, proposedReservePercent: proposedReservePercent,
            changes: changes
        )
    }

    public func report(locale: Locale = .current) throws -> String {
        let comparison = try comparison()
        let language: String?
        if #available(macOS 13, iOS 16, *) { language = locale.language.languageCode?.identifier }
        else { language = locale.languageCode }
        let de = language == "de"
        let number = NumberFormatter(); number.locale = locale; number.minimumFractionDigits = 1; number.maximumFractionDigits = 2
        func liters(_ value: Double, signed: Bool = false) -> String {
            (signed && value > 0 ? "+" : "") + (number.string(from: NSNumber(value: value)) ?? "—") + " l"
        }
        func component(_ value: VolumeComponent) -> String {
            var line = "\(value.name): \(liters(value.totalLiters))"
            if let source = value.source, !source.isEmpty { line += " · \(de ? "Quelle" : "Source"): \(source)" }
            if let note = value.note, !note.isEmpty { line += " · \(note)" }
            return line
        }
        let date = DateFormatter(); date.locale = locale; date.dateStyle = .medium; date.timeStyle = .short
        var lines = [de ? "VolumeCalc · Variantenvergleich" : "VolumeCalc · Design comparison", baselineProjectName, name,
                     "\(de ? "Bestand erfasst" : "Baseline captured"): \(date.string(from: capturedAt))", "",
                     de ? "Bestand → Variante (Differenz)" : "Baseline → Proposal (difference)"]
        let metrics: [(String, Double, Double)] = [
            (de ? "Berechneter Wasserinhalt" : "Calculated water volume", comparison.baselineWaterLiters, comparison.proposedWaterLiters),
            (de ? "Reserve" : "Reserve", comparison.baselineReserveLiters, comparison.proposedReserveLiters),
            (de ? "Planungsvolumen" : "Planning volume", comparison.baselinePlanningLiters, comparison.proposedPlanningLiters)
        ]
        for (label, before, after) in metrics { lines.append("\(label): \(liters(before)) → \(liters(after)) (\(liters(after-before, signed: true)))") }
        lines += ["", de ? "Bauteiländerungen" : "Component changes"]
        if comparison.changes.isEmpty { lines.append(de ? "Keine Bauteiländerungen" : "No component changes") }
        for change in comparison.changes {
            switch change.kind {
            case .added: lines.append("+ " + component(change.after!))
            case .removed: lines.append("− " + component(change.before!))
            case .changed: lines += ["~ " + component(change.before!), "  → " + component(change.after!)]
            }
        }
        lines += ["", de ? "Planungsvariante, keine Messung und kein Nachweis eines Umbaus. Herstellerangaben und Quellen prüfen. Der tatsächliche Bestand und bestehende Füllprüfungen bleiben unverändert." : "Planning scenario, not a measurement or proof of an installed change. Verify manufacturer specifications and sources. The actual inventory and existing fill audits remain unchanged."]
        return lines.joined(separator: "\n")
    }
}

public enum VolumeAlternativeError: Error { case invalidSnapshot }
public struct VolumeComponentChange: Equatable, Sendable {
    public enum Kind: String, Hashable, Sendable { case added, removed, changed }
    public let kind: Kind
    public let componentID: UUID
    public let before: VolumeComponent?
    public let after: VolumeComponent?
}
public struct VolumeAlternativeComparison: Equatable, Sendable {
    public let baselineWaterLiters: Double
    public let proposedWaterLiters: Double
    public let baselineReservePercent: Double
    public let proposedReservePercent: Double
    public let changes: [VolumeComponentChange]
    public var baselineReserveLiters: Double { baselineWaterLiters * baselineReservePercent / 100 }
    public var proposedReserveLiters: Double { proposedWaterLiters * proposedReservePercent / 100 }
    public var baselinePlanningLiters: Double { baselineWaterLiters + baselineReserveLiters }
    public var proposedPlanningLiters: Double { proposedWaterLiters + proposedReserveLiters }
    public var waterDeltaLiters: Double { proposedWaterLiters - baselineWaterLiters }
    public var planningDeltaLiters: Double { proposedPlanningLiters - baselinePlanningLiters }
}
