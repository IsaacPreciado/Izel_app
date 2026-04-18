import Foundation

struct CycleSnapshot {
    let currentDay: Int
    let phase: CyclePhase
    let daysUntilNextPhase: Int
    let totalCycleDays: Int
}

enum CycleCalculatorService {

    static func snapshot(for profile: UserProfile, on date: Date = .now) -> CycleSnapshot {
        let total = max(profile.cycleDurationDays, 21)
        let start = profile.lastPeriodStart ?? date
        let elapsedDays = max(1, Calendar.current.dateComponents([.day], from: start, to: date).day ?? 1)
        let currentDay = ((elapsedDays - 1) % total) + 1

        let phase: CyclePhase
        switch currentDay {
        case 1...5:                       phase = .menstrual
        case 6...13:                      phase = .folicular
        case 14...16:                     phase = .ovulatoria
        default:                          phase = .lutea
        }

        let boundary: Int
        switch phase {
        case .menstrual:    boundary = 6
        case .folicular:    boundary = 14
        case .ovulatoria:   boundary = 17
        case .lutea:        boundary = total + 1
        }

        return CycleSnapshot(
            currentDay: currentDay,
            phase: phase,
            daysUntilNextPhase: max(0, boundary - currentDay),
            totalCycleDays: total
        )
    }
}
