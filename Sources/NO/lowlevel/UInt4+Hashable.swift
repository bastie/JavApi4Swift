/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension UInt4 : Hashable {
  public func hash(into hasher: inout Hasher) {
    // Implementierung der hash(into:) Methode
    hasher.combine(value)
  }
}
