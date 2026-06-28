/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  public protocol ErrorHandler {
    func warning (_ exception : org.xml.sax.SAXParseException) throws (org.xml.sax.SAXException)
    func error (_ exception : SAXParseException) throws (SAXException)
    func fatalError (_ exception : SAXParseException) throws (SAXException)
  }
}
