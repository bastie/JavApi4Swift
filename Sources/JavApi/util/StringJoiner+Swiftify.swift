/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - CustomStringConvertible

extension java.util.StringJoiner: CustomStringConvertible {
  public var description: String { toString() }
  public var count : Int { length() }
}
