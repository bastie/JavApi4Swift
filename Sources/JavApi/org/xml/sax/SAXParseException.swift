/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension org.xml.sax {
  open class SAXParseException : org.xml.sax.SAXException, @unchecked Sendable {
    
    private let locator: org.xml.sax.Locator
    
    public init (_ message: String, _ locator : org.xml.sax.Locator) {
      self.locator = locator
      super.init(message)
    }

    public init (_ message: String, _ locator : org.xml.sax.Locator, _ cause : Throwable) {
      self.locator = locator
      super.init(message, cause)
    }

    public init (_ message: String, _ publicID: String, _ systemID: String, _ lineNumber : Int, _ columnNumber : Int) {
      let locator = org.xml.sax.LocatorImpl()
      locator.setPublicId(publicID)
      locator.setSystemId(systemID)
      locator.setLineNumber(lineNumber)
      locator.setColumnNumber(columnNumber)
      self.locator = locator
      super.init(message)
    }

    public init (_ message: String, _ publicID: String, _ systemID: String, _ lineNumber : Int, _ columnNumber : Int, _ cause : Throwable) {
      let locator = org.xml.sax.LocatorImpl()
      locator.setPublicId(publicID)
      locator.setSystemId(systemID)
      locator.setLineNumber(lineNumber)
      locator.setColumnNumber(columnNumber)
      self.locator = locator
      super.init(message, cause)
    }
    
    public func getPublicId() -> String? {
      self.locator.getPublicId()
    }
    public func getSystemId() -> String? {
      self.locator.getSystemId()
    }
    public func getLineNumber() -> Int {
      self.locator.getLineNumber()
    }
    public func getColumnNumber() -> Int {
      self.locator.getColumnNumber()
    }
  }
}
