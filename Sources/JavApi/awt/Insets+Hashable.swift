/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.Insets : Hashable{
  // -------------------------------------------------------------------------
  // MARK: Equatable & Hashable
  // -------------------------------------------------------------------------
  
  public static func == (lhs: java.awt.Insets, rhs: java.awt.Insets) -> Bool {
    lhs.top == rhs.top && lhs.left  == rhs.left
    && lhs.bottom == rhs.bottom
    && lhs.right  == rhs.right
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(top); hasher.combine(left)
    hasher.combine(bottom); hasher.combine(right)
  }
  
  public func hashCode() -> Int {
    var hasher = Hasher(); hash(into: &hasher); return hasher.finalize()
  }
}
