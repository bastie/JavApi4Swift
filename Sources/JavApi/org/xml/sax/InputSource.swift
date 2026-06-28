/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  public class LocatorImpl : Locator {
    
    /// swift constant extension did not break Java API
    public static let UNKNOWN_LINE_OR_COLUMN = -1
    
    private var lineNumber: Int = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
    private var columnNumber: Int = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
    private var publicId: String?
    private var systemId: String?
    
    public init() {}
    
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
    public func setLineNumber(_ lineNumber: Int) {
      if lineNumber < 1 {
        self.lineNumber = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
      }
      self.lineNumber = lineNumber
    }
    /// 1-based number of column
    /// - Parameter columnNumber: column
    /// - Note: values lesser than 1 would be stored as unknown
    public func setColumnNumber(_ columnNumber: Int) {
      if lineNumber < 1 {
        self.columnNumber = LocatorImpl.UNKNOWN_LINE_OR_COLUMN
      }
      self.columnNumber = columnNumber
    }
    
  }
}
