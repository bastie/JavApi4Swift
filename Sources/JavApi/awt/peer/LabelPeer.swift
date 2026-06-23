/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

@available(*, deprecated, message: "This API is not meant to be called by clients.")
extension java.awt.peer {
  /// - Since: Java 1.0
  @available(*, deprecated, message: "This API is not meant to be called by clients.")
  public protocol LabelPeer: ComponentPeer {
    func setText(_ text: String)
    func setAlignment(_ alignment: Int) throws
  }
}
