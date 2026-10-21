import Foundation

@main struct AlternativeStoreSmoke {
    @MainActor static func main() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("projects.json")
        let store = ProjectStore(fileURL: file)
        var actual = VolumeProject(name: "QA inventory", components: [VolumeComponent(kind: .buffer, name: "Buffer", unitVolumeLiters: 100)])
        var alternative = VolumeAlternative(project: actual, name: "Proposal")
        alternative.proposedComponents[0].unitVolumeLiters = 80
        actual.alternatives = [alternative]
        precondition(store.upsert(actual))
        let saved = try Data(contentsOf: file)
        let reopened = ProjectStore(fileURL: file)
        let recovered = reopened.projects.first { $0.id == actual.id }!
        precondition(recovered.components[0].unitVolumeLiters == 100)
        precondition(recovered.alternatives?.first?.proposedComponents[0].unitVolumeLiters == 80)
        precondition(recovered.alternatives?.first?.baselineComponents[0].unitVolumeLiters == 100)
        var invalid = actual
        invalid.alternatives![0].proposedReservePercent = -1
        precondition(!store.upsert(invalid))
        let unchanged = try Data(contentsOf: file); precondition(unchanged == saved)
        invalid = actual; invalid.alternatives!.append(alternative)
        precondition(!store.upsert(invalid))
        let unchangedAgain = try Data(contentsOf: file); precondition(unchangedAgain == saved)
        let legacyFile = folder.appendingPathComponent("legacy.json")
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        var legacy = actual; legacy.alternatives = nil
        try encoder.encode([legacy]).write(to: legacyFile)
        let imported = ProjectStore(fileURL: legacyFile)
        precondition(imported.projects.first?.alternatives == nil)
        precondition(imported.projects.first?.components == actual.components)
        let damaged = Data("{invalid original bytes".utf8)
        try damaged.write(to: file)
        let protected = ProjectStore(fileURL: file)
        precondition(!protected.upsert(actual))
        let preserved = try Data(contentsOf: file); precondition(preserved == damaged)
        print("PASS: actual store save/reopen, frozen baseline, legacy import, invalid/duplicate alternative rejection and damaged-file preservation")
    }
}
