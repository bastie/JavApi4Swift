/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Array {
  
  /// This is a mapping of property `count` to property Java named length.
  ///
  /// The property of element size is often used in Java also in Swing. To translate Java code you need not replace the name length.
  @inlinable
  public var length : Int {
    get {
      return self.count
    }
  }
}

