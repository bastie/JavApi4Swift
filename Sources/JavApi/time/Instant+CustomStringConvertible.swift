/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: CustomStringConvertible {
  
  /// A textual representation of this instance.
  public var description: String {
    return "\(self.second).\(self.nano)"
  }
  
}
