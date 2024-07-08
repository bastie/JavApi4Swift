/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import XCTest
@testable import JavApi

public class java_util_Random_tests : XCTestCase {
  
  var r = java.util.Random(0)
  
  /**
   * @tests java.util.Random#Random()
   */
  public func test_Constructor() {
    // Test for method java.util.Random()
    _ = java.util.Random()
    XCTAssertTrue(true,"Used to test");
  }
  
  /**
   * @tests java.util.Random#Random(long)
   */
  public func test_ConstructorJ() {
    let r = java.util.Random(Int64(8409238))
    let r2 = java.util.Random(Int64(8409238))
    for _ in 0..<100 {
      XCTAssertTrue(r.nextInt() == r2.nextInt(), "Values from randoms with same seed don't match" )
    }
  }
  
  /**
   * @tests java.util.Random#nextBoolean()
   */
  public func test_nextBoolean() {
    // Test for method boolean java.util.Random.nextBoolean()
    var falseAppeared = false
    var trueAppeared = false;
    for _ in 0..<100 {
      if (r.nextBoolean()) {
        trueAppeared = true;
      }
      else {
        falseAppeared = true;
      }
    }
    XCTAssertTrue(falseAppeared, "Calling nextBoolean() 100 times resulted in all trues")
    XCTAssertTrue(trueAppeared, "Calling nextBoolean() 100 times resulted in all falses")
  }
  
  /**
   * @tests java.util.Random#nextBytes(byte[])
   */
  public func test_nextBytes$B() {
    // Test for method void java.util.Random.nextBytes(byte [])
    var someDifferent = false;
    var randomBytes : [byte] = Array(repeating: byte(), count: 100)
    r.nextBytes(&randomBytes);
    let firstByte = randomBytes[0];
    for counter in 1..<randomBytes.count {
      if (randomBytes[counter] != firstByte) {
        someDifferent = true;
      }
    }
    XCTAssertTrue(someDifferent, "nextBytes() returned an array of length 100 of the same byte")
  }
  
  /**
   * @tests java.util.Random#nextDouble()
   */
  public func test_nextDouble() {
    // Test for method double java.util.Random.nextDouble()
    var lastNum = r.nextDouble();
    var nextNum : Double;
    var someDifferent = false;
    var inRange = true;
    for _ in 0..<100 {
      nextNum = r.nextDouble();
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      if (!(0 <= nextNum && nextNum < 1.0)) {
        inRange = false;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent, "Calling nextDouble 100 times resulted in same number")
    XCTAssertTrue(inRange, "Calling nextDouble resulted in a number out of range [0,1)")
  }
  
  /**
   * @tests java.util.Random#nextFloat()
   */
  public func test_nextFloat() {
    // Test for method float java.util.Random.nextFloat()
    var lastNum = r.nextFloat();
    var nextNum : Float;
    var someDifferent = false;
    var inRange = true;
    for _ in 0..<100 {
      nextNum = r.nextFloat();
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      if (!(0 <= nextNum && nextNum < 1.0)) {
        inRange = false;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent,"Calling nextFloat 100 times resulted in same number")
    XCTAssertTrue(inRange,"Calling nextFloat resulted in a number out of range [0,1)")
  }
  
  /**
   * @tests java.util.Random#nextGaussian()
   */
  public func test_nextGaussian() {
    // Test for method double java.util.Random.nextGaussian()
    var lastNum = r.nextGaussian();
    var nextNum : Double
    var someDifferent = false;
    var someInsideStd = false;
    for _ in 0..<100 {
      nextNum = r.nextGaussian();
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      if (-1.0 <= nextNum && nextNum <= 1.0) {
        someInsideStd = true;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent, "Calling nextGaussian 100 times resulted in same number")
    XCTAssertTrue(someInsideStd, "Calling nextGaussian 100 times resulted in no number within 1 std. deviation of mean")
  }
  
  /**
   * @tests java.util.Random#nextInt()
   */
  public func test_nextInt() {
    // Test for method int java.util.Random.nextInt()
    var lastNum = r.nextInt();
    var nextNum = 0;
    var someDifferent = false;
    for _ in 0..<100 {
      nextNum = r.nextInt();
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent, "Calling nextInt 100 times resulted in same number")
  }
  
  /**
   * @tests java.util.Random#nextInt(int)
   */
  public func test_nextIntI() {
    // Test for method int java.util.Random.nextInt(int)
    let range = 10;
    var lastNum = try! r.nextInt(range);
    var nextNum = 0;
    var someDifferent = false;
    var inRange = true;
    for _ in 0..<100 {
      nextNum = try! r.nextInt(range);
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      if (!(0 <= nextNum && nextNum < range)) {
        inRange = false;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent,"Calling nextInt (range) 100 times resulted in same number")
    XCTAssertTrue(inRange,"Calling nextInt (range) resulted in a number outside of [0, range)")
  }
  
  /**
   * @tests java.util.Random#nextLong()
   */
  public func test_nextLong() {
    // Test for method long java.util.Random.nextLong()
    var lastNum = r.nextLong();
    var nextNum = Int64();
    var someDifferent = false;
    for _ in 0..<100 {
      nextNum = r.nextLong();
      if (nextNum != lastNum) {
        someDifferent = true;
      }
      lastNum = nextNum;
    }
    XCTAssertTrue(someDifferent, "Calling nextLong 100 times resulted in same number")
  }
  
  /**
   * @tests java.util.Random#setSeed(long)
   */
  public func test_setSeedJ() {
    // Test for method void java.util.Random.setSeed(long)
    var randomArray : [Int64] = Array(repeating: Int64(), count: 100)
    var someDifferent = false;
    let firstSeed : Int64 = 1000;
    var aLong : Int64
    var anotherLong : Int64
    var yetAnotherLong : Int64
    let aRandom = java.util.Random();
    let anotherRandom = java.util.Random();
    let yetAnotherRandom = java.util.Random();
    aRandom.setSeed(firstSeed);
    anotherRandom.setSeed(firstSeed);
    for counter in 0..<randomArray.count {
      aLong = aRandom.nextLong();
      anotherLong = anotherRandom.nextLong();
      XCTAssertTrue(aLong == anotherLong, "Two randoms with same seeds gave differing nextLong values")
      yetAnotherLong = yetAnotherRandom.nextLong();
      randomArray[counter] = aLong;
      if (aLong != yetAnotherLong) {
        someDifferent = true;
      }
    }
    XCTAssertTrue(someDifferent,"Two randoms with the different seeds gave the same chain of values");
    aRandom.setSeed(firstSeed);
    for counter in 0..<randomArray.count {
      XCTAssertTrue(aRandom.nextLong() == randomArray[counter], "Reseting a random to its old seed did not result in the same chain of values as it gave before")
    }
  }
  
  // two random create at a time should also generated different results
  // regression test for Harmony 4616
  public func test_random_generate() throws {//Exception {
    for _ in 0..<100 {
      let random1 = java.util.Random();
      Thread.sleep(1) // Swift is to fast, so sleep is needed
      let random2 = java.util.Random();
      XCTAssertFalse(random1.nextLong() == random2.nextLong());
    }
  }
  
  /**
   * Sets up the fixture, for example, open a network connection. This method
   * is called before a test is executed.
   */
  public override func setUp() {
    r = java.util.Random()
  }
  
  /**
   * Tears down the fixture, for example, close a network connection. This
   * method is called after a test is executed.
   */
  override public func tearDown() {
  }
}
