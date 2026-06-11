/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
extension java.awt.toolkit {
  /// Namespace for the X11 toolkit backend (Linux, FreeBSD).
  public enum x11 {}
}
#endif
