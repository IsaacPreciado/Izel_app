import Foundation
import SwiftData

enum PersistenceService {

    static let schema = Schema([
        UserProfile.self,
        SymptomEntry.self,
        CycleEntry.self
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
