/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Windows)
extension java.awt.toolkit {
  /// Namespace for the Windows GDI toolkit backend.
  public enum gdi {}
}
#endif
