/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_math_BigDecimal_Tests {

  @Test("divide and add produce correct result for tax-calculator pseudo code")
  func testDivideAdd() {
    // see pseudo code from German Federal Ministry of Finance
    // https://www.bmf-steuerrechner.de/interface/einganginterface.xhtml
    let ZAHL2   = java.math.BigDecimal.valueOf(2)
    let ZAHL100 = java.math.BigDecimal.valueOf(100)
    var KVSATZAN = java.math.BigDecimal.valueOf(0)
    let KVZ      = java.math.BigDecimal()
    let jamesBond = java.math.BigDecimal.valueOf("0.07")!

    KVSATZAN = (KVZ.divide(ZAHL2).divide(ZAHL100)).add(jamesBond)

    // Compare numerically — avoids NSDecimalNumber.stringValue which is locale-sensitive
    #expect(KVSATZAN == java.math.BigDecimal.valueOf("0.07")!)
  }

  @Test("setScale rounds correctly for positive, zero, and negative scales")
  func testScale() {
    // tax-calculator: 25000 * 0.093 rounded down to 2 decimal places
    var VSP1     = java.math.BigDecimal.valueOf("25000")!
    let RVSATZAN = java.math.BigDecimal.valueOf("0.093000")!
    VSP1 = (VSP1.multiply(RVSATZAN)).setScale(2, java.math.BigDecimal.ROUND_DOWN)
    #expect(VSP1 == java.math.BigDecimal.valueOf("2325.00")!)

    // pi rounded to 2 decimal places
    let pi   = java.math.BigDecimal.valueOf(Double.pi)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_UP)   == 3.15)
    #expect(pi.setScale(2, java.math.BigDecimal.ROUND_DOWN) == 3.14)

    // scale 0
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_DOWN) == 3)
    #expect(pi.setScale(0, java.math.BigDecimal.ROUND_UP)   == 4)

    // scale 0 with large value
    let big = java.math.BigDecimal(1_103_802.8199999998)
    #expect(big.setScale( 1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802.8")!)
    #expect(big.setScale( 0, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103802")!)
    #expect(big.setScale(-1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1103800")!)

    // regression: scale > 0 with digit 5 as last
    let onePoint55 = java.math.BigDecimal.valueOf("1.55")!
    #expect(onePoint55.setScale(1, java.math.BigDecimal.ROUND_DOWN) == java.math.BigDecimal.valueOf("1.5")!)
  }
}
