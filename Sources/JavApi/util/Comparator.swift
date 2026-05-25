/*
 * SPDX-FileCopyrightText: 2025-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  
  public protocol Comparator<T> : SortComparator, Equatable {
    associatedtype T
    func compare (_ lhs: T?, _ rhs: T?) -> Int
    func compare (_ lhs: T, _ rhs: T) -> Int
    
    static func nullsFirst(_ master : any java.util.Comparator<T>) -> any java.util.Comparator<T>
    static func nullsLast(_ master : any java.util.Comparator<T>) -> any java.util.Comparator<T>
  }
}
