/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

struct JavApi_lang_Math_Tests {
  @Test("Test JavApi Math.abs methods")
  public func abs() {
    do {
      var doubleActually : Double = -10.0
      #expect(Math.abs(doubleActually) == 10.0)
      doubleActually = 10.0
      #expect(Math.abs(doubleActually) == 10.0)
      doubleActually = 0.0
      #expect(Math.abs(doubleActually) == 0.0)
      doubleActually = .nan
      #expect(Math.abs(doubleActually).isNaN)
      doubleActually = .infinity
      #expect(Math.abs(doubleActually).isInfinite)
      doubleActually = -Double.infinity
      #expect(Math.abs(doubleActually).isInfinite)
    }
    
    do {
      var intActually : Int = -10
      #expect(Math.abs(intActually) == 10)
      intActually = 10
      #expect(Math.abs(intActually) == 10)
      intActually = 0
      #expect(Math.abs(intActually) == 0)
    }
    
    do {
      var longActually : Int64 = -10
      #expect(Math.abs(longActually) == 10)
      longActually = 10
      #expect(Math.abs(longActually) == 10)
      longActually = 0
      #expect(Math.abs(longActually) == 0)
    }
    
    
    
    
  }
}
