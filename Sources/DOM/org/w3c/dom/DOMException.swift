/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

///
/// - SeeAlso: [SPEC](https://webidl.spec.whatwg.org/#idl-DOMException)
open class DOMException : Error, CustomStringConvertible, @unchecked Sendable {
  public var description: String {
    """
    DOMException
    errorcode: \(code)
    dom message: \(message)
    """
  }
  
  public let code: DOMExceptionCode
  public var message: String {
    DOMException.messages[code] ?? "\(code.rawValue)"
  }
  public let name: String
  
  public init(code: DOMExceptionCode,name: String = "Error") {
    self.code = code
    self.name = name
  }
  
}
