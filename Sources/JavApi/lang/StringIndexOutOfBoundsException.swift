/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

open class StringIndexOutOfBoundsException : IndexOutOfBoundsException, @unchecked Sendable {
  
  public override init () {
    super.init()
  }
  
  public override init (_ message: String) {
    super.init(message)
  }

  public init (_ index : Int) {
    super.init("String index \(index) out of bounds")
  }
  
}
