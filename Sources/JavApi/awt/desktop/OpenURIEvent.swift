/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.desktop {
  
  /// - Since: Java 9
  open class OpenURIEvent : AppEvent, @unchecked Sendable {
    
    private let uri : java.net.URI
    
    internal init(_ uri : java.net.URI) {
      self.uri = uri
      super.init()
    }
    
    public func getURI() -> java.net.URI {
      return uri
    }
  }
}
