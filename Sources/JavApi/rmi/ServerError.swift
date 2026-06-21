/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.rmi {

  /// A ``RemoteException`` wrapping a ``java.lang.Error`` thrown on the server side.
  ///
  /// Java's `ServerError(String s, Error err)` constructor takes a `java.lang.Error`.
  /// In JavApi⁴Swift `java.lang.Error` is part of the `Throwable` hierarchy,
  /// so the standard Throwable-based initialisers cover that case.
  open class ServerError : java.rmi.RemoteException, @unchecked Sendable {

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
