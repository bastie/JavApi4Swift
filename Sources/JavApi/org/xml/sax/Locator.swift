/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  public protocol Locator {
    func getPublicId() -> String?
    func getSystemId() -> String?
    func getLineNumber() -> Int
    func getColumnNumber() -> Int
  }
  
}

extension org.xml.sax.Locator {
  public func getLineNumber() -> Int {
    return -1
  }
  
  public func getColumnNumber() -> Int {
    return -1
  }
}
