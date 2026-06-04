/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {
  open class URISyntaxException : java.lang.Exception, @unchecked Sendable {

    private let index : Int
    private let reason : String
    private let input : String
    
    public init (_ input: String, _ reason : String, _ index : Int = -1) {
      self.index = index
      self.reason = reason
      self.input = input

      let message = "\(reason) \((-1 != index) ? "at index \(index)" : ""): \(input)"
      super.init(message)
    }
    
    public func getIndex() -> Int {
      return index
    }
    public func getReason() -> String {
      return reason
    }
    public func getInput() -> String {
      return input
    }
  }
}
