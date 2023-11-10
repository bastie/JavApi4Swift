/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

/// Extension for FileHandle as TextOutputStream for using in System.err
extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    let data = Data(string.utf8)
    self.write(data)
  }
  
  public func print(_ string: String) {
    self.write(string)
  }
  
  public func println (_ string : String) {
    self.print(string)
    self.print(System.getProperty("line.separator", "\n"))
  }
}

