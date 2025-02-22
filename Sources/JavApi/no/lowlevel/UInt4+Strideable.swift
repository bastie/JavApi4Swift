/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
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
extension UInt4: Strideable {
  public typealias Stride = Int
  
  public func distance(to other: UInt4) -> Stride {
    let selfValue = Int(self.value)
    let otherValue = Int(other.value)
    return otherValue - selfValue
  }
  
  public func advanced(by n: Stride) -> UInt4 {
    let newValue = Int(self.value) + n
    let clampedValue = Swift.max(Swift.min(newValue, 15), 0)
    return UInt4(clamping: clampedValue)
  }
}
