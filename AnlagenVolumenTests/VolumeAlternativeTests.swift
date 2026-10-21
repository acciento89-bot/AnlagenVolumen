import XCTest
@testable import AnlagenVolumenCore

final class VolumeAlternativeTests: XCTestCase {
    func testDraftNumberRejectsVisibleBlankAndInvalidValues() {
        for text in ["", "  ", "NaN", "Infinity", "-1", "1e999", "1,2,3"] {
            XCTAssertNil(VolumeAlternative.parseDraftNumber(text), text)
        }
        XCTAssertEqual(VolumeAlternative.parseDraftNumber(" 1,25 "), 1.25)
        XCTAssertEqual(VolumeAlternative.parseDraftNumber("1.25"), 1.25)
        XCTAssertEqual(VolumeAlternative.parseDraftNumber("0"), 0)
    }

    private func sample() -> VolumeProject {
        VolumeProject(name: "Heizkreis", reservePercent: 10, components: [
            VolumeComponent(kind: .buffer, name: "Speicher", quantity: 1, unitVolumeLiters: 100, source: "Typenschild", note: "Herstellerwert"),
            VolumeComponent(kind: .pipe, name: "Leitung", quantity: 2, unitVolumeLiters: 10)
        ])
    }
    func testIndependentSnapshotAndSeparatedReserveDeltas() throws {
        var actual = sample()
        var proposal = VolumeAlternative(project: actual, name: "Kompakter Speicher")
        proposal.proposedComponents[0].unitVolumeLiters = 80
        proposal.proposedReservePercent = 5
        actual.components[0].unitVolumeLiters = 150
        let result = try proposal.comparison()
        XCTAssertEqual(result.baselineWaterLiters, 120)
        XCTAssertEqual(result.proposedWaterLiters, 100)
        XCTAssertEqual(result.waterDeltaLiters, -20)
        XCTAssertEqual(result.baselineReserveLiters, 12)
        XCTAssertEqual(result.proposedReserveLiters, 5)
        XCTAssertEqual(result.planningDeltaLiters, -27)
        XCTAssertEqual(proposal.baselineComponents[0].unitVolumeLiters, 100)
        XCTAssertTrue(proposal.isBaselineStale(comparedWith: actual))
    }
    func testChangesUseComponentIDsAndDoNotTreatReorderingAsChange() throws {
        let actual = sample()
        var proposal = VolumeAlternative(project: actual, name: "Variante")
        proposal.proposedComponents.reverse()
        XCTAssertTrue(try proposal.comparison().changes.isEmpty)
        var reordered = actual; reordered.components.reverse()
        XCTAssertFalse(proposal.isBaselineStale(comparedWith: reordered))
        proposal.proposedComponents[0].name = "Neue Leitung"
        let removed = proposal.proposedComponents.removeLast()
        let added = VolumeComponent(kind: .radiator, name: "Heizkörper", unitVolumeLiters: 6)
        proposal.proposedComponents.append(added)
        let changes = try proposal.comparison().changes
        XCTAssertEqual(Set(changes.map(\.kind)), Set([.changed, .removed, .added]))
        XCTAssertEqual(changes.first { $0.kind == .removed }?.componentID, removed.id)
        XCTAssertEqual(changes.first { $0.kind == .added }?.componentID, added.id)
    }
    func testLegacyProjectWithoutAlternativesStillLoadsAndRoundTripsSnapshot() throws {
        var actual = sample()
        let legacy = try JSONEncoder().encode(actual)
        XCTAssertNil((try JSONSerialization.jsonObject(with: legacy) as? [String: Any])?["alternatives"])
        actual.alternatives = [VolumeAlternative(project: actual, name: "Variante")]
        let decoded = try JSONDecoder().decode(VolumeProject.self, from: JSONEncoder().encode(actual))
        XCTAssertEqual(decoded.alternatives, actual.alternatives)
        var dictionary = try XCTUnwrap(JSONSerialization.jsonObject(with: legacy) as? [String: Any])
        dictionary.removeValue(forKey: "alternatives")
        let old = try JSONDecoder().decode(VolumeProject.self, from: JSONSerialization.data(withJSONObject: dictionary))
        XCTAssertNil(old.alternatives)
    }
    func testInvalidSnapshotsAndOverflowAreRejected() throws {
        var proposal = VolumeAlternative(project: sample(), name: "Variante")
        proposal.name = "  "
        XCTAssertFalse(proposal.isValid)
        XCTAssertThrowsError(try proposal.comparison())
        proposal.name = "Variante"
        proposal.proposedComponents.append(proposal.proposedComponents[0])
        XCTAssertFalse(proposal.isValid)
        proposal.proposedComponents.removeLast()
        proposal.proposedComponents[0].quantity = -.infinity
        XCTAssertFalse(proposal.isValid)
        proposal.proposedComponents[0].quantity = .greatestFiniteMagnitude
        XCTAssertFalse(proposal.isValid)
        proposal.proposedComponents[0].quantity = 1
        proposal.proposedReservePercent = .nan
        XCTAssertFalse(proposal.isValid)
    }
    func testComparisonReportIncludesUnitsSourceAndPlanningDistinction() throws {
        var proposal = VolumeAlternative(project: sample(), name: "Ohne Speicher")
        proposal.proposedComponents.removeFirst()
        let report = try proposal.report(locale: Locale(identifier: "de_DE"))
        XCTAssertTrue(report.contains("Heizkreis"))
        XCTAssertTrue(report.contains("Ohne Speicher"))
        XCTAssertTrue(report.contains("Typenschild"))
        XCTAssertTrue(report.contains("Herstellerwert"))
        XCTAssertTrue(report.contains("Planungsvolumen"))
        XCTAssertTrue(report.contains(" l"))
        XCTAssertTrue(report.contains("keine Messung"))
    }
}
