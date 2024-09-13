/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Date : Cloneable {
  public func clone() throws -> java.util.Date {
    let copy = java.util.Date()
    copy.delegate = self.delegate
    return copy
  }
  
  public typealias Cloneable = java.util.Date
  
}
