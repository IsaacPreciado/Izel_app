import Foundation
import SwiftData

@Observable
final class OnboardingViewModel {
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    var weightText: String = ""
    var heightText: String = "165"
    var cycleRegularity: CycleRegularity = .regular
    var cycleDurationDays: Int = 28
    var pregnancies: Int = 0
    var abortions: Int = 0

    var isValid: Bool {
        guard let w = Double(weightText.replacingOccurrences(of: ",", with: ".")),
              let h = Double(heightText.replacingOccurrences(of: ",", with: ".")) else { return false }
        return w > 0 && h > 0
    }

    func save(using context: ModelContext) {
        let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let height = Double(heightText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let profile = UserProfile(
            birthDate: birthDate,
            weightKg: weight,
            heightCm: height,
            cycleRegularity: cycleRegularity,
            cycleDurationDays: cycleDurationDays,
            pregnancies: pregnancies,
            abortions: abortions,
            lastPeriodStart: .now
        )
        context.insert(profile)
        try? context.save()
    }
}
