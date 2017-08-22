import Foundation

public struct Period {

    // MARK: - Property

    public var year: Int {
        get { return self.internalYear }
        set { self.internalYear = newValue; self.normalize() }
    }
    public var month: Int {
        get { return self.internalMonth }
        set { self.internalMonth = newValue; self.normalize() }
    }
    public var day: Int {
        get { return self.internalDay }
        set { self.internalDay = newValue; self.normalize() }
    }
    public var hour: Int {
        get { return self.internalHour }
        set { self.internalHour = newValue; self.normalize() }
    }
    public var minute: Int {
        get { return self.internalMinute }
        set { self.internalMinute = newValue; self.normalize() }
    }
    public var second: Int {
        get { return self.internalSecond }
        set { self.internalSecond = newValue; self.normalize() }
    }
    public var nano: Int {
        get { return self.internalNano }
        set { self.internalNano = newValue; self.normalize() }
    }

    // MARK: - Private

    fileprivate var internalYear: Int
    fileprivate var internalMonth: Int
    fileprivate var internalDay: Int
    fileprivate var internalHour: Int
    fileprivate var internalMinute: Int
    fileprivate var internalSecond: Int
    fileprivate var internalNano: Int

    private mutating func normalize() {
        let year = self.internalYear
        let month = self.internalMonth
        let day = self.internalDay
        let hour = self.internalHour
        let minute = self.internalMinute
        let second = self.internalSecond
        let nano = self.internalNano

        var total = Int64(hour) * LocalTime.Constant.nanosPerHour
        total += Int64(minute) * LocalTime.Constant.nanosPerMinute
        total += Int64(second) * LocalTime.Constant.nanosPerSecond
        total += Int64(nano)
        
        let dayAppend: Int
        if total < 0 {
            dayAppend = Int(total / LocalTime.Constant.nanosPerDay) - 1
            total = (Int64(-dayAppend) * LocalTime.Constant.nanosPerDay) + total
        } else {
            dayAppend = Int(total / LocalTime.Constant.nanosPerDay)
            total %= LocalTime.Constant.nanosPerDay
        }
        
        self.internalNano = Int(total % LocalTime.Constant.nanosPerSecond)
        total /= LocalTime.Constant.nanosPerSecond
        
        self.internalSecond = Int(total % Int64(LocalTime.Constant.secondsPerMinute))
        total /= Int64(LocalTime.Constant.secondsPerMinute)
        
        self.internalMinute = Int(total % Int64(LocalTime.Constant.minutesPerHour))
        self.internalHour = Int(total / Int64(LocalTime.Constant.minutesPerHour))

        let days = day + dayAppend

        var newDate = LocalDate(year: year, month: month + 1, day: days + 1)
        self.internalYear = newDate.year
        self.internalMonth = newDate.month - 1
        self.internalDay = newDate.day - 1
    }
    
    
    // MARK: - Operator
    
    /// Period
    static public func + (lhs: Period, rhs: Period) -> Period {
        return Period(
            year: lhs.year + rhs.year,
            month: lhs.month + rhs.month,
            day: lhs.day + rhs.day,
            hour: lhs.hour + rhs.hour,
            minute: lhs.minute + rhs.minute,
            second: lhs.second + rhs.second,
            nano: lhs.nano + rhs.nano
        )
    }
    static public func += (lhs: inout Period, rhs: Period) {
        lhs.year += rhs.year
        lhs.month += rhs.month
        lhs.day += rhs.day
        lhs.hour += rhs.hour
        lhs.minute += rhs.minute
        lhs.second += rhs.second
        lhs.nano += rhs.nano
    }
    static public func - (lhs: Period, rhs: Period) -> Period {
        return Period(
            year: lhs.year - rhs.year,
            month: lhs.month - rhs.month,
            day: lhs.day - rhs.day,
            hour: lhs.hour - rhs.hour,
            minute: lhs.minute - rhs.minute,
            second: lhs.second - rhs.second,
            nano: lhs.nano - rhs.nano
        )
    }
    static public func -= (lhs: inout Period, rhs: Period) {
        lhs.year -= rhs.year
        lhs.month -= rhs.month
        lhs.day -= rhs.day
        lhs.hour -= rhs.hour
        lhs.minute -= rhs.minute
        lhs.second -= rhs.second
        lhs.nano -= rhs.nano
    }
    
    /// LocalDateTime
    static public func + (lhs: LocalDateTime, rhs: Period) -> LocalDateTime {
        return LocalDateTime(
            year: lhs.year + rhs.year,
            month: lhs.month + rhs.month,
            day: lhs.day + rhs.day,
            hour: lhs.hour + rhs.hour,
            minute: lhs.minute + rhs.minute,
            second: lhs.second + rhs.second,
            nanoOfSecond: lhs.nano + rhs.nano
        )
    }
    static public func += (lhs: inout LocalDateTime, rhs: Period) {
        lhs.year += rhs.year
        lhs.month += rhs.month
        lhs.day += rhs.day
        lhs.hour += rhs.hour
        lhs.minute += rhs.minute
        lhs.second += rhs.second
        lhs.nano += rhs.nano
    }
    static public func - (lhs: LocalDateTime, rhs: Period) -> LocalDateTime {
        return LocalDateTime(
            year: lhs.year - rhs.year,
            month: lhs.month - rhs.month,
            day: lhs.day - rhs.day,
            hour: lhs.hour - rhs.hour,
            minute: lhs.minute - rhs.minute,
            second: lhs.second - rhs.second,
            nanoOfSecond: lhs.nano - rhs.nano
        )
    }
    static public func -= (lhs: inout LocalDateTime, rhs: Period) {
        lhs.year -= rhs.year
        lhs.month -= rhs.month
        lhs.day -= rhs.day
        lhs.hour -= rhs.hour
        lhs.minute -= rhs.minute
        lhs.second -= rhs.second
        lhs.nano -= rhs.nano
    }
    
    /// ZonedDateTime
    static public func + (lhs: ZonedDateTime, rhs: Period) -> ZonedDateTime {
        return ZonedDateTime(
            year: lhs.year + rhs.year,
            month: lhs.month + rhs.month,
            day: lhs.day + rhs.day,
            hour: lhs.hour + rhs.hour,
            minute: lhs.minute + rhs.minute,
            second: lhs.second + rhs.second,
            nanoOfSecond: lhs.nano + rhs.nano,
            clock: lhs.clock
        )
    }
    static public func += (lhs: inout ZonedDateTime, rhs: Period) {
        lhs.year += rhs.year
        lhs.month += rhs.month
        lhs.day += rhs.day
        lhs.hour += rhs.hour
        lhs.minute += rhs.minute
        lhs.second += rhs.second
        lhs.nano += rhs.nano
    }
    static public func - (lhs: ZonedDateTime, rhs: Period) -> ZonedDateTime {
        return ZonedDateTime(
            year: lhs.year - rhs.year,
            month: lhs.month - rhs.month,
            day: lhs.day - rhs.day,
            hour: lhs.hour - rhs.hour,
            minute: lhs.minute - rhs.minute,
            second: lhs.second - rhs.second,
            nanoOfSecond: lhs.nano - rhs.nano,
            clock: lhs.clock
        )
    }
    static public func -= (lhs: inout ZonedDateTime, rhs: Period) {
        lhs.year -= rhs.year
        lhs.month -= rhs.month
        lhs.day -= rhs.day
        lhs.hour -= rhs.hour
        lhs.minute -= rhs.minute
        lhs.second -= rhs.second
        lhs.nano -= rhs.nano
    }
    
    
    // MARK: - Lifecycle

    public init(year: Int = 0, month: Int = 0, day: Int = 0, hour: Int = 0, minute: Int = 0, second: Int = 0, nano: Int = 0) {
        self.internalYear = year
        self.internalMonth = month
        self.internalDay = day
        self.internalHour = hour
        self.internalMinute = minute
        self.internalSecond = second
        self.internalNano = nano
        self.normalize()
    }
}

extension Period: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    public static func <(lhs: Period, rhs: Period) -> Bool {
        if lhs.year < rhs.year { return true }
        if lhs.month < rhs.month { return true }
        if lhs.day < rhs.day { return true }
        if lhs.hour < rhs.hour { return true }
        if lhs.minute < rhs.minute { return true }
        if lhs.second < rhs.second { return true }
        if lhs.nano < rhs.nano { return true }
        return false
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than that of the second argument.
    public static func >(lhs: Period, rhs: Period) -> Bool {
        if lhs.year > rhs.year { return true }
        if lhs.month > rhs.month { return true }
        if lhs.day > rhs.day { return true }
        if lhs.hour > rhs.hour { return true }
        if lhs.minute > rhs.minute { return true }
        if lhs.second > rhs.second { return true }
        if lhs.nano > rhs.nano { return true }
        return false
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    public static func <=(lhs: Period, rhs: Period) -> Bool {
        return !(lhs > rhs)
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    public static func >=(lhs: Period, rhs: Period) -> Bool {
        return !(lhs < rhs)
    }
    
}
extension Period: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    public static func ==(lhs: Period, rhs: Period) -> Bool {
        guard lhs.year == rhs.year else { return false }
        guard lhs.month == rhs.month else { return false }
        guard lhs.day == rhs.day else { return false }
        guard lhs.hour == rhs.hour else { return false }
        guard lhs.minute == rhs.minute else { return false }
        guard lhs.second == rhs.second else { return false }
        guard lhs.nano == rhs.nano else { return false }
        return true
    }
    
}
extension Period: CustomStringConvertible, CustomDebugStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        let list: [String?] = [
            self.internalYear != 0 ? String(format: "%04dYear ", self.internalYear) : nil,
            self.internalMonth != 0 ? String(format: "%02dMon ", self.internalMonth) : nil,
            self.internalDay != 0 ? String(format: "%02dDay ", self.internalDay) : nil,
            self.internalHour != 0 ? String(format: "%02dHour ", self.internalHour) : nil,
            self.internalMinute != 0 ? String(format: "%02dMin ", self.internalMinute) : nil,
            self.internalSecond != 0 || self.internalNano != 0 ? String(format: "%02d.%09dSec", self.internalSecond, self.internalNano) : nil
        ]
        
        return list
            .flatMap { $0 }
            .joined()
    }
    
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return description
    }
    
}
extension Period: CustomReflectable {
    public var customMirror: Mirror {
        var c = [(label: String?, value: Any)]()
        c.append((label: "year", value: self.internalYear))
        c.append((label: "month", value: self.internalMonth))
        c.append((label: "day", value: self.internalDay))
        c.append((label: "hour", value: self.internalHour))
        c.append((label: "minute", value: self.internalMinute))
        c.append((label: "second", value: self.internalSecond))
        c.append((label: "nano", value: self.internalNano))
        return Mirror(self, children: c, displayStyle: Mirror.DisplayStyle.struct)
    }
}
extension Period: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(self.description)
    }
}
