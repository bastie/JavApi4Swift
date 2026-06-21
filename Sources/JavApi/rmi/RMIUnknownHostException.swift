/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.rmi {

  /// RMI-specific unknown host exception.
  ///
  /// > Note: This is `java.rmi.UnknownHostException`, which extends
  /// > `RemoteException`. It is distinct from `java.net.UnknownHostException`,
  /// > which extends `IOException`.
  open class UnknownHostException : java.rmi.RemoteException, @unchecked Sendable {

    public override init () {
      super.init()
    }

    public override init (_ message: String) {
      super.init(message)
    }

    public override init (_ newMessage: String, _ newCause: Throwable) {
      super.init(newMessage, newCause)
    }

    public override init (_ newCause: Throwable) {
      super.init(newCause)
    }
  }
}
