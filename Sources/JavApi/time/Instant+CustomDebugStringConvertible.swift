/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: CustomDebugStringConvertible {
  
  /// A textual representation of this instance, suitable for debugging.
  public var debugDescription: String {
    return description
  }
}
