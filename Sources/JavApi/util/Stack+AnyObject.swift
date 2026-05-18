/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util.Stack where E : AnyObject { // ===
  
  /// Returns the 1-based position of `o` from the top of the stack,
  /// or `-1` if `o` is not present.
  ///
  /// The topmost element has distance `1`; the element beneath it `2`, etc.
  /// Uses identity (`===`) for comparison, matching Java's `==` on objects.
  public func search(_ o: E) -> Int {
    withLock {
      // Scan from top (elementCount-1) downward
      for i in stride(from: elementCount - 1, through: 0, by: -1) {
        if elementData[i] === o {
          return elementCount - i   // convert 0-based from-bottom to 1-based from-top
        }
      }
      return -1
    }
  }
  
}
