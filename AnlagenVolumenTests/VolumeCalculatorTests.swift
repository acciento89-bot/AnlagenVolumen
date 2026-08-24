import XCTest
@testable import AnlagenVolumenCore

final class VolumeCalculatorTests: XCTestCase {
    func testPipe16x2At100Meters() {
        let volume = VolumeCalculator.pipeVolumeLiters(innerDiameterMM: 12, lengthMeters: 100)
        XCTAssertEqual(volume, 11.3097, accuracy: 0.001)
    }

    func testCopper22At25Meters() {
        let volume = VolumeCalculator.pipeVolumeLiters(innerDiameterMM: 20, lengthMeters: 25)
        XCTAssertEqual(volume, 7.854, accuracy: 0.001)
    }

    func testGalvanizedSteelDN25Preset() throws {
        let preset = try XCTUnwrap(
            ReferenceData.pipePresets.first {
                $0.group == "Stahl Gewinderohr verzinkt" && $0.name.contains("DN 25")
            }
        )
        XCTAssertEqual(preset.innerDiameterMM, 27.3, accuracy: 0.0001)
        XCTAssertEqual(preset.litersPerMeter, 0.5854, accuracy: 0.001)
    }

    func testBoilerTube604x29Preset() throws {
        let preset = try XCTUnwrap(
            ReferenceData.pipePresets.first {
                $0.group == "Siederohr normalwandig" && $0.name == "60,3 × 2,9 mm"
            }
        )
        XCTAssertEqual(preset.innerDiameterMM, 54.5, accuracy: 0.0001)
        XCTAssertEqual(preset.litersPerMeter, 2.3329, accuracy: 0.001)
    }

    func testPurmoReferenceType22Height600Length1000() throws {
        let ref = try XCTUnwrap(ReferenceData.radiatorReference(type: "22", heightMM: 600))
        XCTAssertEqual(ref.litersPerMeter, 6.6, accuracy: 0.0001)
        XCTAssertEqual(
            VolumeCalculator.radiatorVolumeLiters(litersPerMeter: ref.litersPerMeter, lengthMM: 1000),
            6.6,
            accuracy: 0.0001
        )
    }

    func testSteelSectionRadiator600x110TenSections() throws {
        let ref = try XCTUnwrap(
            ReferenceData.sectionRadiatorReferences.first {
                $0.material == .steel && $0.heightMM == 600 && $0.depthMM == 110
            }
        )
        XCTAssertEqual(ref.litersPerSection, 0.833, accuracy: 0.0001)
        XCTAssertEqual(
            VolumeCalculator.sectionRadiatorVolumeLiters(
                litersPerSection: ref.litersPerSection,
                sections: 10
            ),
            8.33,
            accuracy: 0.001
        )
    }

    func testCastIronSectionRadiator580x220TwelveSections() throws {
        let ref = try XCTUnwrap(
            ReferenceData.sectionRadiatorReferences.first {
                $0.material == .castIron && $0.heightMM == 580 && $0.depthMM == 220
            }
        )
        XCTAssertEqual(ref.litersPerSection, 1.3, accuracy: 0.0001)
        XCTAssertEqual(
            VolumeCalculator.sectionRadiatorVolumeLiters(
                litersPerSection: ref.litersPerSection,
                sections: 12
            ),
            15.6,
            accuracy: 0.001
        )
    }

    func testProjectReserve() {
        var project = VolumeProject(reservePercent: 5)
        project.components = [
            VolumeComponent(kind: .other, name: "A", unitVolumeLiters: 100),
            VolumeComponent(kind: .other, name: "B", quantity: 2, unitVolumeLiters: 25)
        ]
        XCTAssertEqual(project.calculatedVolumeLiters, 150, accuracy: 0.001)
        XCTAssertEqual(project.reserveLiters, 7.5, accuracy: 0.001)
        XCTAssertEqual(project.planningVolumeLiters, 157.5, accuracy: 0.001)
    }

    func testZeroAndNegativeValuesClampToZero() {
        XCTAssertEqual(VolumeCalculator.pipeVolumeLiters(innerDiameterMM: 0, lengthMeters: 10), 0)
        XCTAssertEqual(VolumeCalculator.pipeVolumeLiters(innerDiameterMM: 12, lengthMeters: -1), 0)
        XCTAssertEqual(VolumeCalculator.sectionRadiatorVolumeLiters(litersPerSection: 1, sections: -1), 0)
    }
}
