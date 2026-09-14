/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

/// Coverage for `java.text.ChoiceFormat.nextDouble(_:)`/`previousDouble(_:)`,
/// in particular the NaN/infinite/zero special cases that Java documents and
/// that a naive `Double.nextUp`/`nextDown` delegation would get wrong.
struct JavApi_text_ChoiceFormat_NextDouble_Tests {

  @Test("nextDouble/previousDouble on ordinary finite values step by one ULP")
  func testOrdinaryValues() {
    #expect(java.text.ChoiceFormat.nextDouble(1.0) == 1.0.nextUp)
    #expect(java.text.ChoiceFormat.previousDouble(1.0) == 1.0.nextDown)
    #expect(java.text.ChoiceFormat.nextDouble(1.0) > 1.0)
    #expect(java.text.ChoiceFormat.previousDouble(1.0) < 1.0)
  }

  @Test("nextDouble/previousDouble are inverses of each other for a finite non-zero value")
  func testRoundTrip() {
    let x = 42.5
    #expect(java.text.ChoiceFormat.previousDouble(java.text.ChoiceFormat.nextDouble(x)) == x)
    #expect(java.text.ChoiceFormat.nextDouble(java.text.ChoiceFormat.previousDouble(x)) == x)
  }

  @Test("nextDouble/previousDouble leave NaN unchanged instead of applying a ULP step")
  func testNaNPassesThroughUnchanged() {
    #expect(java.text.ChoiceFormat.nextDouble(Double.nan).isNaN)
    #expect(java.text.ChoiceFormat.previousDouble(Double.nan).isNaN)
  }

  @Test("nextDouble/previousDouble leave infinities unchanged, matching Java's special-casing rather than IEEE nextUp/nextDown")
  func testInfinitiesPassThroughUnchanged() {
    // This is the key divergence from a naive `.nextUp`/`.nextDown` call:
    // IEEE 754 nextUp(-infinity) is the most negative FINITE double, and
    // nextDown(+infinity) is the largest FINITE double -- but Java's
    // ChoiceFormat.nextDouble/previousDouble special-case infinities to
    // return them unchanged.
    #expect(java.text.ChoiceFormat.nextDouble(Double.infinity) == Double.infinity)
    #expect(java.text.ChoiceFormat.nextDouble(-Double.infinity) == -Double.infinity)
    #expect(java.text.ChoiceFormat.previousDouble(Double.infinity) == Double.infinity)
    #expect(java.text.ChoiceFormat.previousDouble(-Double.infinity) == -Double.infinity)
  }

  @Test("nextDouble/previousDouble at zero step to the smallest subnormal double, matching Java's Double.MIN_VALUE")
  func testZeroStepsToSmallestSubnormal() {
    #expect(java.text.ChoiceFormat.nextDouble(0.0) == Double.leastNonzeroMagnitude)
    #expect(java.text.ChoiceFormat.previousDouble(0.0) == -Double.leastNonzeroMagnitude)
    // -0.0 == 0.0 in Swift/Java, so it must be handled the same way.
    #expect(java.text.ChoiceFormat.nextDouble(-0.0) == Double.leastNonzeroMagnitude)
    #expect(java.text.ChoiceFormat.previousDouble(-0.0) == -Double.leastNonzeroMagnitude)
  }

  @Test("applyPattern's '<' operator still uses nextDouble internally, so strict '<' choices behave correctly")
  func testLessThanPatternUsesNextDouble() {
    let cf = java.text.ChoiceFormat("0#none|1<many")
    // format(1.0) must NOT select "many" -- 1<many means strictly greater than 1.
    #expect(cf.format(1.0) == "none")
    #expect(cf.format(java.text.ChoiceFormat.nextDouble(1.0)) == "many")
  }
}
