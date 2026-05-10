/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class InternalError : VirtualMachineError, @unchecked Sendable {
  
  public override init () {
    super.init()
  }
  
  public override init (_ message: String) {
    super.init(message)
  }
  
}
