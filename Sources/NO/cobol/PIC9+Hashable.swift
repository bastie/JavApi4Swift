/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension PIC9 : Hashable {
  public func hash(into hasher: inout Hasher) {
    // Implementierung der hash(into:) Methode
    hasher.combine(value)
  }
}
