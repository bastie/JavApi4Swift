/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.lang.StringBuilder {
  
  /// The number of characters in the builder. Swift-idiomatic alias for ``length()``.
  public var count : Int {
    get {
      return self.length()
    }
  }
}
