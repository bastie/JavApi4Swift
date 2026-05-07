/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

final class JavApi_util_Enumeration_Tests {
  
  @Test("Test JavApi Enumeration methods")
  func testEnumeration () {
    var e = ArrayEnumeration(["alpha", "beta", "gamma"])
    
    var result = ""
    // ── Java-like ──────────────────────────────────
    while e.hasMoreElements() {
      result.append(e.nextElement())
    }
    #expect(result == "alphabetagamma")

    result = ""
    // ── Swift-like: for-in ─────────────────────────
    for value in ArrayEnumeration(["alpha", "beta", "gamma"]) {
      result.append(value)
    }
    #expect(result == "alphabetagamma")
    
    // ── Swift-like: höhere Funktionen ──────────────
    let upper = ArrayEnumeration(["alpha", "beta", "gamma"]).map { $0.uppercased() }
    // → ["ALPHA", "BETA", "GAMMA"]
    #expect(upper[0]=="ALPHA" && upper[1]=="BETA" && upper[2]=="GAMMA")
  }
  
  
}

struct ArrayEnumeration<Element>: java.util.Enumeration {
  private let storage: [Element]
  private var index: Int = 0
  
  public init(_ array: [Element]) {
    self.storage = array
  }
  
  public func hasMoreElements() -> Bool {
    index < storage.count
  }
  
  public mutating func nextElement() -> Element {
    defer { index += 1 }
    return storage[index]
  }
}
