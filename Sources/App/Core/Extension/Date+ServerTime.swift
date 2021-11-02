import Foundation

extension Date {
    static var serverTime: UInt {
        UInt(Date.timeIntervalBetween1970AndReferenceDate)
    }
}
