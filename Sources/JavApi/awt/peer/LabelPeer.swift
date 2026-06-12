/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.peer {
  /// - Since: Java 1.0
  public protocol LabelPeer: ComponentPeer {
    func setText(_ text: String)
    func setAlignment(_ alignment: Int) throws
  }
}
