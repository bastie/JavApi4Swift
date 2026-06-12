/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.Container : java.awt.peer.ContainerPeer {
  /// If in JavApi⁴Swift components render themselves — there is no separate native
  /// peer object.  Each component IS its own peer.
  /// - Returns: the container's insets.
  public func insets() -> java.awt.Insets { java.awt.Insets(0, 0, 0, 0) }
}

