import Foundation
import Combine

@MainActor
final class ProjectStore: ObservableObject {
    @Published var projects: [VolumeProject] = []
    @Published var selectedProjectID: UUID?

    init() { load() }

    var selectedProject: VolumeProject? {
        get {
            if let id = selectedProjectID, let project = projects.first(where: { $0.id == id }) { return project }
            return projects.first
        }
        set {
            guard let newValue else { return }
            upsert(newValue)
            selectedProjectID = newValue.id
        }
    }

    func createProject(name: String = "Neue Anlage") {
        let project = VolumeProject(name: name)
        projects.insert(project, at: 0)
        selectedProjectID = project.id
        save()
    }

    func upsert(_ project: VolumeProject) {
        var changed = project
        changed.updatedAt = .now
        if let index = projects.firstIndex(where: { $0.id == changed.id }) {
            projects[index] = changed
        } else {
            projects.insert(changed, at: 0)
        }
        projects.sort { $0.updatedAt > $1.updatedAt }
        save()
    }

    func deleteProject(_ project: VolumeProject) {
        projects.removeAll { $0.id == project.id }
        if selectedProjectID == project.id { selectedProjectID = projects.first?.id }
        if projects.isEmpty { createProject() } else { save() }
    }

    private var fileURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("volumecalc-projects.json")
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            projects = try JSONDecoder.app.decode([VolumeProject].self, from: data)
        } catch {
            projects = [VolumeProject()]
        }
        selectedProjectID = projects.first?.id
    }

    private func save() {
        do {
            let data = try JSONEncoder.app.encode(projects)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Project save failed: \(error)")
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
