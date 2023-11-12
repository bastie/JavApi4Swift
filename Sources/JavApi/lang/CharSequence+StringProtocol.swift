/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension CharSequence where Self : StringProtocol {
  
  public func subSequence (_ start: Int, _ end : Int) -> String {
    let result : SubSequence = self.subSequence(start, end)
    let asString = String (result)
    return asString
  }
  
}


