/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.util.Date : Equatable {
  public static func == (lhs: java.util.Date, rhs: java.util.Date) -> Bool {
    return lhs.delegate == rhs.delegate
  }
}
