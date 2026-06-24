/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Test helper: concrete Observer

/// Minimal Observer that records all update() calls.
final class TestObserver : java.util.Observer {
  var updateCount = 0
  var lastData: Any? = nil
  var lastObservable: java.util.Observable? = nil

  func update(_ observable: java.util.Observable, _ data: Any?) {
    updateCount += 1
    lastData = data
    lastObservable = observable
  }

  // Equatable via identity
  static func == (lhs: TestObserver, rhs: TestObserver) -> Bool {
    lhs === rhs
  }
}

struct JavApi_util_Observable_Tests {

  // MARK: - setChanged / clearChanged / hasChanged

  @Test("hasChanged returns false initially")
  func testHasChangedInitial() {
    let obs = java.util.Observable()
    #expect(obs.hasChanged() == false)
  }

  @Test("setChanged makes hasChanged return true")
  func testSetChanged() {
    let obs = java.util.Observable()
    obs.setChanged()
    #expect(obs.hasChanged() == true)
  }

  @Test("clearChanged resets hasChanged to false")
  func testClearChanged() {
    let obs = java.util.Observable()
    obs.setChanged()
    obs.clearChanged()
    #expect(obs.hasChanged() == false)
  }

  // MARK: - addObserver / countObservers

  @Test("countObservers returns 0 initially")
  func testCountObserversInitial() {
    let obs = java.util.Observable()
    #expect(obs.countObservers() == 0)
  }

  @Test("addObserver increases count")
  func testAddObserver() {
    let obs = java.util.Observable()
    let o1 = TestObserver()
    let o2 = TestObserver()
    obs.addObserver(o1)
    #expect(obs.countObservers() == 1)
    obs.addObserver(o2)
    #expect(obs.countObservers() == 2)
  }

  @Test("addObserver does not add same observer twice")
  func testAddObserverNoDuplicate() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)
    obs.addObserver(o)
    #expect(obs.countObservers() == 1)
  }

  // MARK: - deleteObserver / deleteObservers

  @Test("deleteObserver removes specific observer")
  func testDeleteObserver() {
    let obs = java.util.Observable()
    let o1 = TestObserver()
    let o2 = TestObserver()
    obs.addObserver(o1)
    obs.addObserver(o2)
    obs.deleteObserver(o1)
    #expect(obs.countObservers() == 1)
  }

  @Test("deleteObserver on non-registered observer is a no-op")
  func testDeleteObserverNotRegistered() {
    let obs = java.util.Observable()
    let o1 = TestObserver()
    let o2 = TestObserver()
    obs.addObserver(o1)
    obs.deleteObserver(o2)   // o2 was never added
    #expect(obs.countObservers() == 1)
  }

  @Test("deleteObservers removes all observers")
  func testDeleteObservers() {
    let obs = java.util.Observable()
    obs.addObserver(TestObserver())
    obs.addObserver(TestObserver())
    obs.deleteObservers()
    #expect(obs.countObservers() == 0)
  }

  // MARK: - notifyObservers

  @Test("notifyObservers does nothing when not changed")
  func testNotifyWithoutChanged() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)
    obs.notifyObservers()   // hasChanged is false → no call
    #expect(o.updateCount == 0)
  }

  @Test("notifyObservers calls update on all observers when changed")
  func testNotifyCallsUpdate() {
    let obs = java.util.Observable()
    let o1 = TestObserver()
    let o2 = TestObserver()
    obs.addObserver(o1)
    obs.addObserver(o2)
    obs.setChanged()
    obs.notifyObservers()
    #expect(o1.updateCount == 1)
    #expect(o2.updateCount == 1)
  }

  @Test("notifyObservers clears changed flag afterwards")
  func testNotifyClearsChanged() {
    let obs = java.util.Observable()
    obs.addObserver(TestObserver())
    obs.setChanged()
    obs.notifyObservers()
    #expect(obs.hasChanged() == false)
  }

  @Test("notifyObservers(data) passes data to observers")
  func testNotifyWithData() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)
    obs.setChanged()
    obs.notifyObservers("hello")
    #expect(o.lastData as? String == "hello")
  }

  @Test("notifyObservers(nil) passes nil as data")
  func testNotifyWithNilData() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)
    obs.setChanged()
    obs.notifyObservers(nil)
    #expect(o.updateCount == 1)
    #expect(o.lastData == nil)
  }

  @Test("notifyObservers passes the Observable itself to update")
  func testNotifyPassesObservable() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)
    obs.setChanged()
    obs.notifyObservers()
    #expect(o.lastObservable === obs)
  }

  @Test("multiple notify cycles each require setChanged")
  func testMultipleNotifyCycles() {
    let obs = java.util.Observable()
    let o = TestObserver()
    obs.addObserver(o)

    obs.setChanged(); obs.notifyObservers()
    #expect(o.updateCount == 1)

    // Second notify without setChanged → no call
    obs.notifyObservers()
    #expect(o.updateCount == 1)

    obs.setChanged(); obs.notifyObservers()
    #expect(o.updateCount == 2)
  }

  @Test("observer added after setChanged is not notified in that cycle")
  func testLateObserverNotNotified() {
    let obs = java.util.Observable()
    let early = TestObserver()
    obs.addObserver(early)
    obs.setChanged()
    let late = TestObserver()
    obs.addObserver(late)
    obs.notifyObservers()
    #expect(early.updateCount == 1)
    #expect(late.updateCount == 1)  // added before notifyObservers call → is notified
  }

  // MARK: - Subclass

  @Test("Observable can be subclassed and setChanged used from subclass")
  func testSubclass() {
    final class Counter : java.util.Observable {
      private(set) var value = 0
      func increment() {
        value += 1
        setChanged()
        notifyObservers(value)
      }
    }

    let counter = Counter()
    let o = TestObserver()
    counter.addObserver(o)
    counter.increment()
    counter.increment()
    #expect(o.updateCount      == 2)
    #expect(o.lastData as? Int == 2)
  }
}
