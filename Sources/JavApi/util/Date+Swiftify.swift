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
  
  /// Seconds since 1 January 1970 UTC as a `TimeInterval` (`Double`).
  ///
  /// Convenience bridge to Swift's `Foundation.Date.timeIntervalSince1970`,
  /// so that `java.util.Date` can be used directly where a `TimeInterval` is expected.
  ///
  /// - Since: JavaApi (Swift bridge)
  public var timeIntervalSince1970: Foundation.TimeInterval {
    return delegate.timeIntervalSince1970
  }
  
}
