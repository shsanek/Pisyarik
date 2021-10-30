import Foundation

extension Date {
    static var serverTime: UInt {
        return UInt(Date.timeIntervalBetween1970AndReferenceDate)
    }
}
