/*
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: CustomDebugStringConvertible {
  
  /// A textual representation of this instance, suitable for debugging.
  public var debugDescription: String {
    return description
  }
}
