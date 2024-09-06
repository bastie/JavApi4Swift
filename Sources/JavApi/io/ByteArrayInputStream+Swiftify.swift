/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io.ByteArrayInputStream {
  
  public convenience init(array : Data) {
    self.init([UInt8](array))
  }

  public convenience init(array : Data, fromOffset : Int, inLength : Int) {
    self.init([UInt8](array), fromOffset, inLength)
  }
}
