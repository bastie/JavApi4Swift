/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_math_BigDecimal_Tests: XCTestCase {
  
  public func testDivideAdd () {
    /// see pseudo code from German Federal Ministry of Finance [income tax calculator](https://www.bmf-steuerrechner.de/interface/einganginterface.xhtml)
    
    let ZAHL2 = java.math.BigDecimal.valueOf(2)
    let ZAHL100 = java.math.BigDecimal.valueOf(100)
    var KVSATZAN = java.math.BigDecimal.valueOf(0)
    let KVZ = java.math.BigDecimal()
    let jamesBond = java.math.BigDecimal.valueOf("0.07")!
    
    KVSATZAN = (KVZ.divide(ZAHL2).divide(ZAHL100)).add(jamesBond)
    
    XCTAssertEqual((KVSATZAN as NSDecimalNumber).stringValue, "0.07")
  }
  
}
