/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension PIC9 : CustomReflectable {
  public var customMirror: Mirror {
    let children: [Mirror.Child] = [
      ("value", value),
      ("count", count),
      ("lossless description", description),
      ("debug description", debugDescription)
    ]
    return Mirror(self, children: children)
  }
}
