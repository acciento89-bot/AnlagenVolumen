import Foundation
import Combine

@MainActor
final class ProjectStore: ObservableObject {
    @Published var projects: [VolumeProject] = []
    @Published var selectedProjectID: UUID?
    @Published var error: String?
    private var loadFailed = false

    init() { load() }

    var selectedProject: VolumeProject? {
        get {
            if let id = selectedProjectID, let project = projects.first(where: { $0.id == id }) { return project }
            return projects.first
        }
        set {
            guard let newValue else { return }
            if upsert(newValue) { selectedProjectID = newValue.id }
        }
    }

    func createProject(name: String = "Neue Anlage") {
        let project = VolumeProject(name: name)
        if persist([project] + projects) { selectedProjectID = project.id }
    }

    @discardableResult func upsert(_ project: VolumeProject) -> Bool {
        guard project.reservePercent.isFinite, project.reservePercent >= 0,
              project.components.allSatisfy({ $0.quantity.isFinite && $0.quantity >= 0 && $0.unitVolumeLiters.isFinite && $0.unitVolumeLiters >= 0 }),
              (project.fillChecks ?? []).allSatisfy(\.isValid) else {
            error = "Nicht gespeichert: Bitte gültige Mengen und Reserven eingeben."
            return false
        }
        var changed = project
        changed.updatedAt = .now
        var next = projects
        if let index = next.firstIndex(where: { $0.id == changed.id }) { next[index] = changed }
        else { next.insert(changed, at: 0) }
        next.sort { $0.updatedAt > $1.updatedAt }
        return persist(next)
    }

    func deleteProject(_ project: VolumeProject) {
        var next = projects.filter { $0.id != project.id }
        if next.isEmpty { next = [VolumeProject()] }
        if persist(next), selectedProjectID == project.id { selectedProjectID = next.first?.id }
    }

    private var fileURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("volumecalc-projects.json")
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            projects = [VolumeProject()]; selectedProjectID = projects.first?.id; return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            projects = try JSONDecoder.app.decode([VolumeProject].self, from: data)
        } catch {
            loadFailed = true
            self.error = "Vorhandene Projekte konnten nicht geöffnet werden. Die Datei bleibt unverändert; Speichern ist zum Schutz der Daten gesperrt."
        }
        selectedProjectID = projects.first?.id
    }

    private func persist(_ next: [VolumeProject]) -> Bool {
        guard !loadFailed else { error = "Speichern gesperrt, um vorhandene Daten zu erhalten. Bitte App-Support kontaktieren."; return false }
        do {
            let data = try JSONEncoder.app.encode(next)
            try data.write(to: fileURL, options: [.atomic])
            projects = next
            return true
        } catch {
            self.error = "Nicht gespeichert. Bitte freien Gerätespeicher prüfen und erneut versuchen."
            return false
        }
    }

}

private extension JSONEncoder {
    static var app: JSONEncoder {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]; encoder.dateEncodingStrategy = .iso8601; return encoder
    }
}
private extension JSONDecoder {
    static var app: JSONDecoder {
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601; return decoder
    }
}
