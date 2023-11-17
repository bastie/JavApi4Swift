/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

open class Thread {
  
  /// Let the current thread sleep
  /// - Parameters:
  /// - Parameter milliseconds to wait
  @available(*, renamed: "sleep", message: "with Swift 5.5 or higher use await/async with sleep(nanoseconds) instead")
  public static func sleep (_ milliseconds : Int64) {
    let group = DispatchGroup()
    group.enter()
    _ = group.wait(timeout: .now() + DispatchTimeInterval.milliseconds(Int(milliseconds)))
  }
}
