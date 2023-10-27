/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util {
  typealias TimeZone = JavApi.TimeZone
}


protocol TimeZone {
  var delegate : Foundation.TimeZone { get set }
}

extension TimeZone {

  static func getAvailableIDs () -> [String] {
    let availableIDs = Foundation.TimeZone.knownTimeZoneIdentifiers
    // TODO: add Java TimeZones for compatibility
    
    return availableIDs
  }
  // static getAvaulableIDs (_ rawOffset : Int) -> [String]
  // static getDefault ()
}

public class SimpleTimeZone : TimeZone {
  var delegate: Foundation.TimeZone
  
  init () {
    self.delegate = Foundation.TimeZone.current
  }

}
