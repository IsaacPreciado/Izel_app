import Foundation
import SwiftData

@Model
final class UserProfile {
    var birthDate: Date
    var weightKg: Double
    var heightCm: Double
    var cycleRegularityRaw: String
    var cycleDurationDays: Int
    var pregnancies: Int
    var abortions: Int
    var createdAt: Date
    var lastPeriodStart: Date?

    init(
        birthDate: Date = .now,
        weightKg: Double = 0,
        heightCm: Double = 0,
        cycleRegularity: CycleRegularity = .regular,
        cycleDurationDays: Int = 28,
        pregnancies: Int = 0,
        abortions: Int = 0,
        lastPeriodStart: Date? = nil
    ) {
        self.birthDate = birthDate
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.cycleRegularityRaw = cycleRegularity.rawValue
        self.cycleDurationDays = cycleDurationDays
        self.pregnancies = pregnancies
        self.abortions = abortions
        self.createdAt = .now
        self.lastPeriodStart = lastPeriodStart
    }

    var cycleRegularity: CycleRegularity {
        get { CycleRegularity(rawValue: cycleRegularityRaw) ?? .regular }
        set { cycleRegularityRaw = newValue.rawValue }
    }

    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let m = heightCm / 100
        return weightKg / (m * m)
    }
}
