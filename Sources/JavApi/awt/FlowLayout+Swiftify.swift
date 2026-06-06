/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.FlowLayout {

  /// Type and value safe convencience constructor
  public convenience init (align : java.awt.FlowLayoutAlignment, hgap : UInt, vgap : UInt) {
    self.init(align.rawValue, Int(hgap), Int(vgap))
  }
}
