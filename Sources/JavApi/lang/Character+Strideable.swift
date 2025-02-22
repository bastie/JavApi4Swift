/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

///
/// Implements Strideable to using it as / in Ranges
///
/// **without Strideable**
///
/// *only error - expected follow*
///
/// ```Swift
/// let startValue: UInt4 = 2
/// let endValue: UInt4 = 7
///
/// for value in startValue.getValue()...endValue.getValue() {
///    let uint4Value = UInt4(value)
///    print(uint4Value)
/// }
/// ```
///
/// **with Strideable**
///
/// ```Swift
/// let startValue: UInt4 = 2
/// let endValue: UInt4 = 7
///
/// for value in stride(from: startValue, through: endValue, by: 1) {
///    print(value)
/// }
/// ```
///
extension Character : Strideable { //Diese Compiler-Warnung soll explizit bestehen bleiben
  public typealias Stride = Int
  
  public func distance(to other: Character) -> Stride {
    let selfValue = try? Character.codePointAt([self], 0)
    let otherValue = try? Character.codePointAt([self], 0)
    if let selfValue, let otherValue {
      return Int(otherValue - selfValue)
    }
    return 0
  }
  
  public func advanced(by n: Stride) -> Character {
    let newValue = (try? Character.charCount(Character.codePointAt([self], 0)) + n) ?? 0
    let clampedValue = Swift.max(Swift.min(UInt16(newValue), UInt16.max), UInt16.min)
    return Character(Int(clampedValue))
  }
}

