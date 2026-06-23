/*
 * SPDX-FileCopyrightText: 2023 - 2026 Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Swift.Set bridge: Java-style add()

extension Swift.Set {

  public mutating func add(_ newElement: Element) -> Bool {
    let result = self.insert(newElement)
    return result.inserted
  }
}
