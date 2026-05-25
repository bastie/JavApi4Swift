/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

struct NilsFirstComparator<T>: java.util.Comparator, SortComparator {
  var order: SortOrder = .forward
  
  let baseComparator : any java.util.Comparator<T>
  internal init (_ master : any java.util.Comparator<T>) {
    baseComparator = master
  }
  
  func compare(_ lhs: T, _ rhs: T) -> Int {
    return baseComparator.compare(lhs, rhs)
  }
  
  func compare(_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _): return -1
    case (_, nil): return 1
    default: return baseComparator.compare(lhs!, rhs!)
    }
  }
  
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let result : Int = self.compare(lhs, rhs)
    if result < 0 { return .orderedAscending }
    if result > 0 { return .orderedDescending }
    return .orderedSame
  }
  
  // - MARK: Implements Equatable
  static func == (lhs: NilsFirstComparator<T>, rhs: NilsFirstComparator<T>) -> Bool {
    // Da wir 'any Comparator' haben, ist ein direkter Vergleich schwierig.
    return ObjectIdentifier(lhs.baseComparator as AnyObject) == ObjectIdentifier(rhs.baseComparator as AnyObject)
  }
  
  // - MARK: Implements Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(baseComparator as AnyObject))
  }
}
