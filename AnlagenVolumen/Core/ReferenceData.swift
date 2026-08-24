import Foundation

public enum ReferenceData {
    /// Presets use nominal outer diameter × wall thickness. Brand-specific multilayer dimensions may differ.
    public static let pipePresets: [PipePreset] = [
        .init(group: "Kupfer", name: "12 × 1 mm", innerDiameterMM: 10, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "15 × 1 mm", innerDiameterMM: 13, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "18 × 1 mm", innerDiameterMM: 16, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "22 × 1 mm", innerDiameterMM: 20, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "28 × 1,5 mm", innerDiameterMM: 25, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "35 × 1,5 mm", innerDiameterMM: 32, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "42 × 1,5 mm", innerDiameterMM: 39, note: "Außen-Ø minus 2 × Wandstärke"),
        .init(group: "Kupfer", name: "54 × 2 mm", innerDiameterMM: 50, note: "Außen-Ø minus 2 × Wandstärke"),

        .init(group: "Mehrschichtverbund", name: "16 × 2 mm", innerDiameterMM: 12, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "20 × 2 mm", innerDiameterMM: 16, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "26 × 3 mm", innerDiameterMM: 20, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "32 × 3 mm", innerDiameterMM: 26, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "40 × 3,5 mm", innerDiameterMM: 33, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "50 × 4 mm", innerDiameterMM: 42, note: "Typischer Dimensionspreset – Hersteller prüfen"),
        .init(group: "Mehrschichtverbund", name: "63 × 4,5 mm", innerDiameterMM: 54, note: "Typischer Dimensionspreset – Hersteller prüfen"),

        .init(group: "PE-X / FBH", name: "12 × 2 mm", innerDiameterMM: 8, note: "Hersteller prüfen"),
        .init(group: "PE-X / FBH", name: "14 × 2 mm", innerDiameterMM: 10, note: "Hersteller prüfen"),
        .init(group: "PE-X / FBH", name: "16 × 2 mm", innerDiameterMM: 12, note: "Hersteller prüfen"),
        .init(group: "PE-X / FBH", name: "17 × 2 mm", innerDiameterMM: 13, note: "Hersteller prüfen"),
        .init(group: "PE-X / FBH", name: "20 × 2 mm", innerDiameterMM: 16, note: "Hersteller prüfen")
    ]

    public static let radiatorDatasetName = "Purmo Plan Compact Referenztabelle (Wasserinhalt je lfd. m)"

    /// Manufacturer-specific reference values from Purmo Plan Compact technical documentation.
    /// These are not universal values for all panel radiators.
    public static let radiatorReferences: [RadiatorReference] = [
        .init(type: "10", heightMM: 500, litersPerMeter: 2.7, dataset: radiatorDatasetName),
        .init(type: "10", heightMM: 550, litersPerMeter: 3.0, dataset: radiatorDatasetName),
        .init(type: "10", heightMM: 600, litersPerMeter: 3.2, dataset: radiatorDatasetName),
        .init(type: "10", heightMM: 900, litersPerMeter: 4.5, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 300, litersPerMeter: 1.6, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 400, litersPerMeter: 2.2, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 500, litersPerMeter: 2.7, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 550, litersPerMeter: 2.9, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 600, litersPerMeter: 3.2, dataset: radiatorDatasetName),
        .init(type: "11", heightMM: 900, litersPerMeter: 4.5, dataset: radiatorDatasetName),
        .init(type: "21S", heightMM: 500, litersPerMeter: 5.4, dataset: radiatorDatasetName),
        .init(type: "21S", heightMM: 550, litersPerMeter: 6.1, dataset: radiatorDatasetName),
        .init(type: "21S", heightMM: 600, litersPerMeter: 6.5, dataset: radiatorDatasetName),
        .init(type: "21S", heightMM: 900, litersPerMeter: 9.0, dataset: radiatorDatasetName),
        .init(type: "21S", heightMM: 950, litersPerMeter: 9.1, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 300, litersPerMeter: 3.4, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 400, litersPerMeter: 4.5, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 500, litersPerMeter: 5.5, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 550, litersPerMeter: 6.1, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 600, litersPerMeter: 6.6, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 900, litersPerMeter: 9.0, dataset: radiatorDatasetName),
        .init(type: "22", heightMM: 950, litersPerMeter: 9.3, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 300, litersPerMeter: 5.1, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 400, litersPerMeter: 6.7, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 500, litersPerMeter: 8.2, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 550, litersPerMeter: 9.0, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 600, litersPerMeter: 9.8, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 900, litersPerMeter: 13.3, dataset: radiatorDatasetName),
        .init(type: "33", heightMM: 950, litersPerMeter: 14.0, dataset: radiatorDatasetName)
    ]

    public static func radiatorReference(type: String, heightMM: Int) -> RadiatorReference? {
        radiatorReferences.first { $0.type == type && $0.heightMM == heightMM }
    }
}
