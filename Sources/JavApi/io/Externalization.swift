/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {

  public protocol Externalizable {
    func writeExternal(_ to : ObjectOutput) throws
    func readExternal(_ from : ObjectInput) throws
  }
}
