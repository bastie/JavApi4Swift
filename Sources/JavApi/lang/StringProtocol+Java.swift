/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension StringProtocol {
  public func subSequence(_ start: Int, _ end: Int) -> SubSequence {
    let lower = index(self.startIndex, offsetBy: start)
    let upper = index(lower, offsetBy: end - start)
    return self[lower..<upper]
  }
  
  public func substring (_ start : Int, _ end : Int) -> String {
    return String(self.subSequence(start,end))
  }
  
  public func substring (_ start: Int) -> String {
    return String(self.subSequence(start, self.count))
  }
}

