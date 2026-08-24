import Foundation

public enum ComponentKind: String, Codable, CaseIterable, Sendable {
    case pipe
    case floorHeating
    case radiator
    case buffer
    case heatGenerator
    case hydraulicSeparator
    case other

    public var title: String {
        switch self {
        case .pipe: return "Rohrleitung"
        case .floorHeating: return "Fußbodenheizung"
        case .radiator: return "Heizkörper"
        case .buffer: return "Puffer / Speicher"
        case .heatGenerator: return "Wärmeerzeuger"
        case .hydraulicSeparator: return "Hydraulische Weiche"
        case .other: return "Sonstiges"
        }
    }
}

public struct VolumeComponent: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var kind: ComponentKind
    public var name: String
    public var quantity: Double
    public var unitVolumeLiters: Double
    public var source: String?
    public var note: String?

    public init(
        id: UUID = UUID(),
        kind: ComponentKind,
        name: String,
        quantity: Double = 1,
        unitVolumeLiters: Double,
        source: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.quantity = max(0, quantity)
        self.unitVolumeLiters = max(0, unitVolumeLiters)
        self.source = source
        self.note = note
    }

    public var totalLiters: Double { quantity * unitVolumeLiters }
}

public struct VolumeProject: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    public var reservePercent: Double
    public var components: [VolumeComponent]

    public init(
        id: UUID = UUID(),
        name: String = "Neue Anlage",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        reservePercent: Double = 5,
        components: [VolumeComponent] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reservePercent = max(0, reservePercent)
        self.components = components
    }

    public var calculatedVolumeLiters: Double {
        components.reduce(0) { $0 + $1.totalLiters }
    }

    public var reserveLiters: Double {
        calculatedVolumeLiters * reservePercent / 100
    }

    public var planningVolumeLiters: Double {
        calculatedVolumeLiters + reserveLiters
    }
}

public struct PipePreset: Identifiable, Hashable, Sendable {
    public let id: String
    public let group: String
    public let name: String
    public let innerDiameterMM: Double
    public let note: String

    public init(group: String, name: String, innerDiameterMM: Double, note: String = "") {
        self.group = group
        self.name = name
        self.innerDiameterMM = innerDiameterMM
        self.note = note
        self.id = "\(group)-\(name)-\(innerDiameterMM)"
    }

    public var litersPerMeter: Double {
        VolumeCalculator.pipeVolumeLiters(innerDiameterMM: innerDiameterMM, lengthMeters: 1)
    }
}

public struct RadiatorReference: Identifiable, Hashable, Sendable {
    public let type: String
    public let heightMM: Int
    public let litersPerMeter: Double
    public let dataset: String

    public var id: String { "\(dataset)-\(type)-\(heightMM)" }

    public init(type: String, heightMM: Int, litersPerMeter: Double, dataset: String) {
        self.type = type
        self.heightMM = heightMM
        self.litersPerMeter = litersPerMeter
        self.dataset = dataset
    }
}
