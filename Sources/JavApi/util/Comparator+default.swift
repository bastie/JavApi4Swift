/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension java.util.Comparator {
  
  public func compare (_ lhs: T?, _ rhs: T?) -> Int {
    switch (lhs, rhs) {
    case (nil, nil): return 0
    case (nil, _): return -1
    case (_, nil): return 1
    default:
      return self.compare(lhs!, rhs!)
    }
  }
  
  static public func nullsFirst(_ master : any java.util.Comparator<T>) -> any java.util.Comparator<T> {
    return NilsFirstComparator(master)
  }
  static func nullsLast(_ master : any java.util.Comparator<T>) -> any java.util.Comparator<T> {
    return NilsLastComparator(master)
  }
}
