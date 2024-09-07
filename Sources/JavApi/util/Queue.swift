/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  protocol Queue<Element> : Collection {
    associatedtype Element
    
    func add (_ elem : Element) throws -> Bool
    func element () throws -> Element
    func offer (_ elem : Element) -> Bool
    func peek () -> Element?
    func poll () -> Element?
    func remove () throws -> Element
  }
  
}

