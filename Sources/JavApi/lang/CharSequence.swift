/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

public protocol CharSequence {
  associatedtype CharSequence : StringProtocol
  
  func subSequence (_ start: Int, _ end : Int) -> CharSequence
  
  func toString () -> String
}
