/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension Foundation.TimeZone {

  // FreeBSD does not provide the property gmt in Swift 5.10.1 so let us help to fly Swift
  #if os(FreeBSD) // at the moment only Swift 5.10 over pkg provided
  public static var gmt: Foundation.TimeZone {
    return Foundation.TimeZone (identifier: "GMT")!
  }
  #else
  #endif
}
