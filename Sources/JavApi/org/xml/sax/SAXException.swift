/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension org.xml.sax {
  open class SAXException : java.lang.Exception, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
    
    public override init (_ message: String) {
      super.init(message)
    }

    public override init (_ message: String, _ cause: Throwable) {
      super.init(message, cause)
    }
  }
}
