/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class TypeNotPresentException : RuntimeException, @unchecked Sendable {
  
  public override init (_ typeName : String, _ newCause : Throwable?) {
    super.init("\(typeName) not present")
    if let newCause {
      do {
        try self.initCause(newCause)
      } catch _ {}
    }
  }
}
