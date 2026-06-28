/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

extension org.xml.sax {
  
  /// - Since: SAX 1.0
  open class InputSource {
    
    private var publicId: String?
    private var systemId: String?
    private var byteStream: java.io.InputStream?
    private var encoding: String?
    private var charReader: java.io.Reader?
    
    public init () {}
    public init (_ systemId: String) {
      self.systemId = systemId
      do {
        _ = try java.net.URL(systemId)
      }
      catch _ {
        java.util.logging.Logger.getLogger("JavAPI").log(java.util.logging.LogRecord(.SEVERE, "systemID URL can not be resolved"))
      }
    }
    public init (_ byteStream : java.io.InputStream) {
      self.byteStream = byteStream
    }
    public init (_ charReader : java.io.Reader) {
      self.charReader = charReader
    }
    public func getSystemId () -> String? {
      systemId
    }
    public func setSystemId (_ systemId: String?) {
      self.systemId = systemId
    }
    public func setPublicId (_ publicId: String?) {
      self.publicId = publicId
    }
    public func getPublicId () -> String? {
      publicId
    }
    public func getByteStream () -> java.io.InputStream? {
      return self.byteStream
    }
    public func setByteStream (_ byteStream: java.io.InputStream?) {
      self.byteStream = byteStream
    }
    public func getCharacterStream () -> java.io.Reader? {
      return self.charReader
    }
    public func setCharacterStream (_ charReader: java.io.Reader?) {
      self.charReader = charReader
    }
    public func getEncoding () -> String? {
      encoding
    }
    public func setEncoding (_ encoding: String?) {
      self.encoding = encoding
    }
  }
}
