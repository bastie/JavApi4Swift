/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Dictionary {
  
  public func get (_ name : Key?) throws -> Value? {
    if let name {
      return self[name]
    }
    
    throw Throwable.NullPointerException("In result of key is nil, NullPointerException ist throwing")
  }
}
