/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  public protocol ErrorHandler {
    func warning (_ exception : SAXParseException) throws (SAXEception)
    func error (_ exception : SAXParseException) throws (SAXEception)
    func fatalError (_ exception : SAXParseException) throws (SAXEception)
  }
}
