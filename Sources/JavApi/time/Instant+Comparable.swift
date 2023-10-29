/*
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: Comparable {
  
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than that of the second argument.
  public static func <(lhs: java.time.Instant, rhs: java.time.Instant) -> Bool {
    guard lhs.second == rhs.second else { return lhs.second < rhs.second }
    return lhs.nano < rhs.nano
  }
  
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is greater than that of the second argument.
  public static func >(lhs: java.time.Instant, rhs: java.time.Instant) -> Bool {
    guard lhs.second == rhs.second else { return lhs.second > rhs.second }
    return lhs.nano > rhs.nano
  }
  
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is less than or equal to that of the second argument.
  public static func <=(lhs: java.time.Instant, rhs: java.time.Instant) -> Bool {
    return !(lhs > rhs)
  }
  
  /// Returns a Boolean value indicating whether the value of the first
  /// argument is greater than or equal to that of the second argument.
  public static func >=(lhs: java.time.Instant, rhs: java.time.Instant) -> Bool {
    return !(lhs < rhs)
  }
  
}
