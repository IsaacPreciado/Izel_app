import Foundation
import SwiftData

@Model
final class CycleEntry {
    var startDate: Date
    var endDate: Date?
    var cycleLengthDays: Int
    var note: String

    init(startDate: Date, endDate: Date? = nil, cycleLengthDays: Int = 28, note: String = "") {
        self.startDate = startDate
        self.endDate = endDate
        self.cycleLengthDays = cycleLengthDays
        self.note = note
    }
}
