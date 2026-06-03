/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com> and contributors
 * SPDX-License-Identifier: Apache-2.0
 */
import Testing
@testable import JavApi

// TODO: Expand tests for java.util.TimeZone / SimpleTimeZone

struct JavApi_util_TimeZone_Tests {

  @Test("SimpleTimeZone.getAvailableIDs returns a non-empty list")
  func testGetAvailableIDsIsNotEmpty() {
    #expect(SimpleTimeZone.getAvailableIDs().count > 0)
  }
}
