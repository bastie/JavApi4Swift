/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  public protocol Comparator<T>  {
    associatedtype T
    func compare (_ lhs: T, _ rhs: T) -> Int
  }
}
