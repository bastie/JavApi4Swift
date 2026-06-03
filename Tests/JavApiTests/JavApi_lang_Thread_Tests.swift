/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Thread_Tests {

  @Test("Thread.sleep waits at least the requested duration with limited overhead")
  func testSleep() {
    let waiting: Int64 = 1_000
    let before = System.currentTimeMillis()
    Thread.sleep(waiting)
    let after = System.currentTimeMillis()

    let diff         = after - before
    let actuallyDiff = diff - waiting

    // minimum waiting time must be respected
    #expect(actuallyDiff >= 0, "Waiting time is \(waiting) ms, actual diff is \(diff) ms")

    // Linux CI runners have higher scheduler latency; 50 ms is a safe upper bound
    let expectedMaximumDiff: Int64 = 50
    #expect(expectedMaximumDiff > actuallyDiff,
            "Overhead \(actuallyDiff) ms exceeded limit of \(expectedMaximumDiff) ms")
  }
}
