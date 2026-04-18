import SwiftUI
import SwiftData

@main
struct Izel_DataApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceService.makeContainer())
    }
}
