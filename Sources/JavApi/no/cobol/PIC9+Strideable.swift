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
extension PIC9: Strideable {
  public typealias Stride = Int128
  
  public func distance(to other: PIC9) -> Stride {
    let selfValue = self.value
    let otherValue = other.value
    return Int128(otherValue - selfValue)
  }
  
  public func advanced(by n: Stride) -> PIC9 {
    let newValue = Int128(self.value) + n
    let clampedValue = Swift.max(Swift.min(newValue, Int128(PIC9.max)), Int128(PIC9.min))
    return PIC9(clamping: clampedValue)
  }
}
