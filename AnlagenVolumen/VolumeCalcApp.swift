import SwiftUI

@main
struct VolumeCalcApp: App {
    @StateObject private var store = ProjectStore()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store).preferredColorScheme(.dark)
        }
    }
}
