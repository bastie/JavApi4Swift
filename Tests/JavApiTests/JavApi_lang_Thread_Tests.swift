/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import XCTest
@testable import JavApi

final class JavApi_lang_Thread_Tests: XCTestCase {
  
  public func testSleep () {
    let waiting : Int64 = 1_000
    let before = System.currentTimeMillis()
    Thread.sleep(waiting)
    let after = System.currentTimeMillis()
    
    let diff = after-before
    let actuallyDiff = diff-waiting
    
    // check that minimum waiting time is slept
    XCTAssertTrue(actuallyDiff >= 0, "Waiting time is \(waiting), diff time is \(diff)")
    
    let expectedMaximumDiff = 5
    
    // check that function call overhead is not to much
    XCTAssertTrue(expectedMaximumDiff>actuallyDiff)
    
    
    
    /// example for async/await
    ///
    /*
     Task {
      let waiting : Int64 = 10_000
      let before = System.currentTimeMillis()
      await Thread.sleep(milliseconds: waiting)
      let after = System.currentTimeMillis()
      
      let actuallyDiff = waiting-(after-before)
      let expectedMaximumDiff = 0
      /// print ("\(after)-\(before)=\(after-before) distance to \(waiting)=\(waiting-(after-before))")
      
    }
    */
  }
  
}
