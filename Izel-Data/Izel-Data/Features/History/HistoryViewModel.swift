import Foundation

struct SymptomFrequency: Identifiable {
    let id: String
    let name: String
    let occurrences: Int
    let trend: Trend

    enum Trend { case up, down, stable }
}

@Observable
final class HistoryViewModel {
    var intensityByDay: [(day: Date, intensity: Int)] = []
    var frequentSymptoms: [SymptomFrequency] = []
    var predictionDescription: String = "Predicción basada en tus últimos 3 ciclos. Se estabiliza la intensidad con tendencia a bajar."

    func load(entries: [SymptomEntry]) {
        let calendar = Calendar.current
        let now = Date.now
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let sixtyDaysAgo  = calendar.date(byAdding: .day, value: -60, to: now)!

        let recent = entries.filter { $0.date >= thirtyDaysAgo }
        let previous = entries.filter { $0.date >= sixtyDaysAgo && $0.date < thirtyDaysAgo }

        // intensityByDay: group recent entries by calendar day, average intensity
        let grouped = Dictionary(grouping: recent) {
            calendar.startOfDay(for: $0.date)
        }
        intensityByDay = grouped.map { day, dayEntries in
            let avg = dayEntries.map(\.intensity).reduce(0, +) / max(1, dayEntries.count)
            return (day: day, intensity: avg)
        }.sorted { $0.day < $1.day }

        // frequentSymptoms: count all symptom IDs across recent entries, top 5
        var recentCounts: [String: Int] = [:]
        for entry in recent {
            for id in entry.symptomIDs {
                recentCounts[id, default: 0] += 1
            }
        }
        var previousCounts: [String: Int] = [:]
        for entry in previous {
            for id in entry.symptomIDs {
                previousCounts[id, default: 0] += 1
            }
        }

        frequentSymptoms = recentCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .compactMap { id, count -> SymptomFrequency? in
                guard let symptom = Symptom.find(id: id) else { return nil }
                let prevCount = previousCounts[id] ?? 0
                let trend: SymptomFrequency.Trend
                if count > prevCount { trend = .up }
                else if count < prevCount { trend = .down }
                else { trend = .stable }
                return SymptomFrequency(id: id, name: symptom.name, occurrences: count, trend: trend)
            }
    }
}
