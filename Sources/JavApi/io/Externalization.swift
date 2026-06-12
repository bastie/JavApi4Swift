/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  /// - Since: Java 1.2
  public protocol Externalizable {
    func writeExternal(_ to : ObjectOutput) throws
    func readExternal(_ from : ObjectInput) throws
  }
}
