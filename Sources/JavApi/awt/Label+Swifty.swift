/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.Label {
  
  /// Creates a label with the given text and alignment without IllegalArgumentException risk
  ///
  /// - Parameters:
  ///   - text:      The text to display.
  ///   - alignment: LabelAlignment enum constants
  ///
  /// - Attention: This is a JavApi⁴Swift extension of the Java API. It improves the Swift port but renders it incompatible. Its use is recommended if you are performing the porting process only once.
  public convenience init (display text: String, with alignment: java.awt.LabelAlignment) {
    try! self.init(text, alignment.rawValue)
  }

  /// Safe setting the alignment of this Label.
  ///
  /// - Parameter alignment: enum value for new alignment of Label
  ///
  /// - Attention: This is a JavApi⁴Swift extension of the Java API. It improves the Swift port but renders it incompatible. Its use is recommended if you are performing the porting process only once.
  public func setAlignment (alignment: java.awt.LabelAlignment) {
    try! self.setAlignment(alignment.rawValue)
  }

}
