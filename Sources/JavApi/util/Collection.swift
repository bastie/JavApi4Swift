/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  public protocol Collection<Element> {
    associatedtype Element
    
    func clear () throws
    func isEmpty () -> Bool
  }
}
