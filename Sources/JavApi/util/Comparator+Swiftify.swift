/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.Comparator  {
  
  func compare(_ lhs: T, _ rhs: T) -> ComparisonResult {
    let result = self.compare(lhs, rhs)
    if result < 0 { return .orderedAscending }
    if result > 0 { return .orderedDescending }
    return .orderedSame
  }
}
