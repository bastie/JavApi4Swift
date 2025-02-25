/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension System {
  public static var `in`: java.io.InputStream {
    get {
      return SystemIn()
    }
  }
  
  public class SystemIn : java.io.InputStream {
    
    public override init() {}
    
    private var buffer: [Character] = []
    
    public override func read() -> Int {
      if buffer.isEmpty {
        let line = readLine(strippingNewline: false)
        if let line {
          buffer = line.toCharArray()
        }
        else {
          return -1
        }
      }
      let character: Character = buffer.removeFirst()
      return Int(character)
    }
    
    internal func readString() -> String? {
      if buffer.isEmpty {
        let line = readLine(strippingNewline: false)
        if let line {
          buffer = line.toCharArray()
          return line
        }
        return nil
      }
      let line = String(buffer)
      buffer = []
      return line
    }
  }
}

