/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// This Instant extension encapsulate the compatibility layer for AnyDate users in respect of the AnyDate project
extension java.time.Instant {
  
  @available(*, deprecated, renamed: "EPOCH", message: "this implementation is for compatibility")
  public static var epoch: java.time.Instant { return java.time.Instant.EPOCH}
  
  @available(*, deprecated, renamed: "MIN", message: "this implementation is for compatibility")
  public static var min: java.time.Instant { return java.time.Instant.MIN }
  
  @available(*, deprecated, renamed: "MAX", message: "this implementation is for compatibility")
  public static var max: java.time.Instant { return java.time.Instant.MAX }

  // AnyDate compatible
  @available(*, deprecated, renamed: "plusSeconds", message: "this implementation is for compatibility")
  public func plus(second: Int64) -> java.time.Instant {
    return self.plusSeconds(second)
  }
  
}
