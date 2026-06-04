/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  open class WriteAbortedException : ObjectStreamException, @unchecked Sendable {

    @available(*, deprecated, renamed: "getCause()", message: "use getCause() instead")
    public var detail : Throwable {getCause()!} // HINT: instead of set in constructor use computed variable, because I do not want self get this deprecation info
    
    
    public override init (_ newMessage : String, _ newCause : Throwable) {
      super.init(newMessage, newCause)
    }
  }
}
