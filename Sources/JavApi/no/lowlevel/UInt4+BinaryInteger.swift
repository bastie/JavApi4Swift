/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: BinaryInteger {
    public typealias Words = UInt8.Words
    //public typealias Words = [UInt]
    // for ClosedRange<UInt4>
    static public var min: UInt4 { return UInt4(0) }
    // for ClosedRange<UInt4>
    static public var max: UInt4 { return UInt4(15) }
    public init<T>(_truncatingBits bits: T) where T: BinaryInteger {
            let clampedValue = UInt8(truncatingIfNeeded: bits) & 0x0F
            value = clampedValue
        }
    
    public var trailingZeroBitCount: Int {
        return value.trailingZeroBitCount
    }
    
    /*public init<T>(clamping source: T) where T: BinaryInteger {
        let clampedValue = UInt8(clamping: source) & 0x0F
        value = clampedValue
    }*/
    
    public init<T>(clamping source: T) where T: BinaryInteger {
        let clampedValue = Swift.max(UInt8(0), Swift.min(UInt8(source), UInt8(UInt4.max)))
        self.init(clampedValue)
    }
    public init<T>(exactly source: T) where T: BinaryInteger {
        guard let UIntValue = UInt8(exactly: source), UIntValue <= 0x0F else {
            fatalError("Invalid value for Nibble. Value must be between 0 and 15.")
        }
        value = UIntValue
    }
    
    public init(_ uint4: UInt4) {
            self.init(uint4.getValue())
        }

    public var words: UInt8.Words {
        return UInt8(value).words
    }
        
    public func wordsFullWidth() -> UInt8.Words {
        return words
    }
    
    
    public static func / (lhs: UInt4, rhs: UInt4) -> UInt4 {
        var result = lhs
        result.value = (lhs.value / rhs.value) & 0x0F
        return result
    }
    public static func /= (lhs: inout UInt4, rhs: UInt4) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: UInt4, rhs: UInt4) -> UInt4 {
        guard rhs != 0 else {
                fatalError("Division by zero")
            }
            
            let result = UInt4(truncatingIfNeeded: UInt(lhs) % UInt(rhs))
            return result
    }
    
    public static func %= (lhs: inout UInt4, rhs: UInt4) {
        lhs = lhs % rhs
    }
    
    public static func & (lhs: UInt4, rhs: UInt4) -> UInt4 {
        let result = UInt4(truncatingIfNeeded: UInt(lhs) & UInt(rhs))
        return result
    }
    
    public static func &= (lhs: inout UInt4, rhs: UInt4) {
        lhs = lhs & rhs
    }
    
    public static func | (lhs: UInt4, rhs: UInt4) -> UInt4 {
            let result = UInt4(truncatingIfNeeded: UInt(lhs) | UInt(rhs))
            return result
        }
    public static func |= (lhs: inout UInt4, rhs: UInt4) {
        lhs = lhs | rhs
    }
    
    public static func ^ (lhs: UInt4, rhs: UInt4) -> UInt4 {
        let result = UInt4(truncatingIfNeeded: UInt(lhs) ^ UInt(rhs))
        return result
    }
    public static func ^= (lhs: inout UInt4, rhs: UInt4) {
        lhs = lhs ^ rhs
    }
    
}
