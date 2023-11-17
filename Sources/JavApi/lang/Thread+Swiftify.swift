/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension Thread {
  
  /// Sleep await/async implementation
  /// - Parameters:
  /// - Parameter nanoseconds waiting time in nanoseconds
  public static func sleep (nanoseconds : UInt64) async {
    try! await Task.sleep(nanoseconds: nanoseconds)
  }
  
  /// Sleep await/async implementation
  /// - Parameters:
  /// - Parameter milliseconds waiting time in milliseconds
  public static func sleep (milliseconds : Int64) async {
    try! await Task.sleep(nanoseconds: UInt64(milliseconds * 1000))
  }
}
