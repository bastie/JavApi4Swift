/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension char {
  public init (_ codePoint : Int) {
    var asString = ""
    let asArray : [UnicodeScalar] = [UnicodeScalar(codePoint)!]
    asString = String(String.UnicodeScalarView(asArray))
    // A single UnicodeScalar always produces a non-empty String, so
    // index 0 is always in bounds.
    self.init(unicodeScalarLiteral: try! asString.charAt(0))
  }
}
