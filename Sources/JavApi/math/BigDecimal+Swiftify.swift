/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.math.BigDecimal {
  
  public static func valueOf (_ newValue : String) -> java.math.BigDecimal? {
    return java.math.BigDecimal(string: newValue)
  }
}
