/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.net {
  open class HttpRetryException : java.io.IOException, @unchecked Sendable {

    private let theResponseCode : Int
    private let location : String
    
    public init (_ detail: String, _ responseCode : Int, _ location : String = "") {
      self.theResponseCode = responseCode
      self.location = location

      super.init(detail)
    }
    
    public func responseCode() -> Int {
      return theResponseCode
    }
    public func getReason() -> String {
      return self.getLocalizedMessage()?.toString() ?? self.getMessage()?.toString() ?? "\(self.theResponseCode)"
    }
    public func getLocation() -> String {
      return location
    }
  }
}
