/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  open class LocatorImpl : Locator {
    
    /// swift constant extension did not break Java API
    public static let UNKNOWN_LINE_OR_COLUMN = -1
    
    private var lineNumber: Int = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
    private var columnNumber: Int = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
    private var publicId: String?
    private var systemId: String?
    
    public init() {}
    public init (_ copyOf: Locator) {
      self.columnNumber = copyOf.getColumnNumber()
      self.lineNumber = copyOf.getLineNumber()
      self.publicId = copyOf.getPublicId()
      self.systemId = copyOf.getSystemId()
    }
    
    public func getPublicId() -> String? {
      return publicId
    }
    public func getSystemId() -> String? {
      return systemId
    }
    public func getLineNumber() -> Int {
      return lineNumber
    }
    public func getColumnNumber() -> Int {
      return columnNumber
    }
    
    public func setPublicId(_ publicId: String?) {
      self.publicId = publicId
    }
    public func setSystemId(_ systemId: String?) {
      self.systemId = systemId
    }
    /// 1-based line number; values less than 1 are stored as ``UNKNOWN_LINE_OR_COLUMN``.
    public func setLineNumber(_ lineNumber: Int) {
      if lineNumber < 1 {
        self.lineNumber = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
        return
      }
      self.lineNumber = lineNumber
    }
    /// 1-based column number; values less than 1 are stored as ``UNKNOWN_LINE_OR_COLUMN``.
    public func setColumnNumber(_ columnNumber: Int) {
      if columnNumber < 1 {
        self.columnNumber = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
        return
      }
      self.columnNumber = columnNumber
    }
    
  }
}
