/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension AssertionError {
  
  public convenience init (_ message: Int8) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: UInt8) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: Int16) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: UInt16) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: Int32) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: UInt32) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: Int64) {
    self.init("\(message)", nil)
  }

  public convenience init (_ message: UInt64) {
    self.init("\(message)", nil)
  }

  public convenience init (_ message: Int128) {
    self.init("\(message)", nil)
  }
  
  public convenience init (_ message: UInt128) {
    self.init("\(message)", nil)
  }

}
