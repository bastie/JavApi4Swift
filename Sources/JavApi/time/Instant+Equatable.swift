/*
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: Equatable {
  
  /// Returns a Boolean value indicating whether two values are equal.
  public static func ==(lhs: java.time.Instant, rhs: java.time.Instant) -> Bool {
    return lhs.second == rhs.second && lhs.nano == rhs.nano
  }
  
}
