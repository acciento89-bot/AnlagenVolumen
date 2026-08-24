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

    func testPurmoReferenceType22Height600Length1000() throws {
        let ref = try XCTUnwrap(ReferenceData.radiatorReference(type: "22", heightMM: 600))
        XCTAssertEqual(ref.litersPerMeter, 6.6, accuracy: 0.0001)
        XCTAssertEqual(VolumeCalculator.radiatorVolumeLiters(litersPerMeter: ref.litersPerMeter, lengthMM: 1000), 6.6, accuracy: 0.0001)
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
    }
}
