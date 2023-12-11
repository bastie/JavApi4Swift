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
 
  public func testScale () {
    /// see pseudo code from German Federal Ministry of Finance [income tax calculator](https://www.bmf-steuerrechner.de/interface/einganginterface.xhtml)
    var VSP1 = java.math.BigDecimal.valueOf("25000")!
    let RVSATZAN = java.math.BigDecimal.valueOf("0.093000")!
    
    VSP1 = (VSP1.multiply(RVSATZAN)).setScale(2,java.math.BigDecimal.ROUND_DOWN)
    XCTAssertEqual(VSP1, java.math.BigDecimal.valueOf("2325.00")!)

    // simple round of PI
    let pi = java.math.BigDecimal.valueOf(Double.pi)
    let up = pi.setScale(2, java.math.BigDecimal.ROUND_UP)
    let down = pi.setScale(2, java.math.BigDecimal.ROUND_DOWN)
    
    XCTAssertEqual(up, 3.15)
    XCTAssertEqual(down, 3.14)
    
    // scale 0 test
    
    let downZero = pi.setScale(0, java.math.BigDecimal.ROUND_DOWN)
    let upZero = pi.setScale(0, java.math.BigDecimal.ROUND_UP)
    
    XCTAssertEqual(downZero, 3)
    XCTAssertEqual(upZero, 4)
    
    // scale 0 second test
    let toRoundWithZero = java.math.BigDecimal (1103802.8199999998);
    let roundOne = toRoundWithZero.setScale (1, java.math.BigDecimal.ROUND_DOWN);
    let roundZero = toRoundWithZero.setScale (0, java.math.BigDecimal.ROUND_DOWN);
    let roundMinusOne = toRoundWithZero.setScale (-1, java.math.BigDecimal.ROUND_DOWN);
    
    XCTAssertEqual(roundOne, java.math.BigDecimal.valueOf("1103802.8")!)
    XCTAssertEqual(roundZero, java.math.BigDecimal.valueOf("1103802")!)
    XCTAssertEqual(roundMinusOne, java.math.BigDecimal.valueOf("1.10380E+6")!)


    // issue in 0.7.4 => scale > 0 & 5 as last
    let onePoint55 = java.math.BigDecimal.valueOf("1.55")!
    let onePoint5 = onePoint55.setScale(1, java.math.BigDecimal.ROUND_DOWN)
    XCTAssertEqual(onePoint5, java.math.BigDecimal.valueOf("1.5")!)
  }
}
