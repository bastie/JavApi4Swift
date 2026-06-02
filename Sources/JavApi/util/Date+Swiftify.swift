/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

import Foundation

extension java.util.Date : CustomStringConvertible {
  public var description: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE MMM dd hh:mm:ss zzz yyyy"
    
    let result: String = dateFormatter.string(from: self.delegate)
    return result
  }
  
}
