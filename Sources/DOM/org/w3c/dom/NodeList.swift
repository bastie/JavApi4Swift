/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.w3c.dom {
  
  public protocol NodeList {
    func item (_ index : Int) -> Node    
    func getLength() -> Int
  }
}
