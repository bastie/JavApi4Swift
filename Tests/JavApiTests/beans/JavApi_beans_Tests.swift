/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Swift 6.3.2 compiler workaround
//
// Using === inside #expect() on a class that has a custom == operator causes a
// fatal SILGen crash in the full JavApi4Swift test target with Swift 6.3.2
// (custom Toolchain swift-6.3.2-RELEASE):
//
//   error: fatal error encountered during compilation
//   note: Invalid conformance in type-checked AST
//   (crash while emitting reabstraction thunk for the #expect closure)
//
// The crash only reproduces in the full project (40+ test files compiled
// together); a minimal standalone package does not trigger it, so no upstream
// bug report has been filed yet.
//
// Workarounds applied throughout this file:
//   1. Identity comparisons use ObjectIdentifier instead of ===:
//        #expect(ObjectIdentifier(a) == ObjectIdentifier(b))
//   2. Bean/source objects use private helper classes (SomeInt, SomeLong,
//      SomeShort) instead of Integer/Long/Short, to avoid Numeric conformance
//      on objects passed to #expect.
private final class SomeLong: AnyObject {
  let v: Int64
  init(_ v: Int64) { self.v = v }
}
private final class SomeInt: AnyObject {
  let v: Int
  init(_ v: Int) { self.v = v }
}
private final class SomeShort: AnyObject {
  let v: Int16
  init(_ v: Int16) { self.v = v }
}

// MARK: - PropertyChangeEvent

struct JavApi_beans_PropertyChangeEvent_Tests {

  @Test("stores source, propertyName, oldValue and newValue")
  func testProperties() {
    let source = SomeInt(1)
    let old    = SomeLong(2)
    let new_   = SomeShort(3)
    let evt    = java.beans.PropertyChangeEvent(source, "color", old, new_)
    #expect(ObjectIdentifier(evt.getSource()) == ObjectIdentifier(source))
    #expect(evt.getPropertyName() == "color")
    #expect(evt.getOldValue().map(ObjectIdentifier.init) == ObjectIdentifier(old))
    #expect(evt.getNewValue().map(ObjectIdentifier.init) == ObjectIdentifier(new_))
  }

  @Test("propertyName may be nil")
  func testNilPropertyName() {
    let source = SomeLong(0)
    let evt    = java.beans.PropertyChangeEvent(source, nil, nil, nil)
    #expect(evt.getPropertyName() == nil)
  }

  @Test("propagationId round-trip")
  func testPropagationId() {
    let source = SomeShort(0)
    let evt    = java.beans.PropertyChangeEvent(source, "x", nil, nil)
    #expect(evt.getPropagationId() == nil)
    let pid = SomeInt(99)
    evt.setPropagationId(pid)
    #expect(evt.getPropagationId().map(ObjectIdentifier.init) == ObjectIdentifier(pid))
    evt.setPropagationId(nil)
    #expect(evt.getPropagationId() == nil)
  }
}

// MARK: - PropertyChangeSupport

struct JavApi_beans_PropertyChangeSupport_Tests {

  // Helper listener that records received events
  final class Recorder: java.beans.PropertyChangeListener {
    var events: [java.beans.PropertyChangeEvent] = []
    func propertyChange(_ evt: java.beans.PropertyChangeEvent) {
      events.append(evt)
    }
  }

  @Test("global listener receives all events")
  func testGlobalListener() {
    let bean     = SomeInt(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)

    support.firePropertyChange("x", nil, nil)
    support.firePropertyChange("y", nil, nil)
    #expect(recorder.events.count == 2)
  }

  @Test("named listener only receives matching property")
  func testNamedListener() {
    let bean     = SomeLong(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener("color", recorder)

    support.firePropertyChange("color", nil, nil)
    support.firePropertyChange("size",  nil, nil)
    #expect(recorder.events.count == 1)
    #expect(recorder.events[0].getPropertyName() == "color")
  }

  @Test("removePropertyChangeListener stops delivery")
  func testRemoveGlobal() {
    let bean     = SomeShort(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)
    support.removePropertyChangeListener(recorder)
    support.firePropertyChange("x", nil, nil)
    #expect(recorder.events.isEmpty)
  }

  @Test("removePropertyChangeListener for named property stops delivery")
  func testRemoveNamed() {
    let bean     = SomeInt(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener("x", recorder)
    support.removePropertyChangeListener("x", recorder)
    support.firePropertyChange("x", nil, nil)
    #expect(recorder.events.isEmpty)
  }

  @Test("hasListeners reflects registration state")
  func testHasListeners() {
    let bean    = SomeLong(0)
    let support = java.beans.PropertyChangeSupport(bean)
    let r       = Recorder()
    #expect(!support.hasListeners("x"))
    support.addPropertyChangeListener("x", r)
    #expect(support.hasListeners("x"))
    support.removePropertyChangeListener("x", r)
    #expect(!support.hasListeners("x"))
  }

  @Test("Int overload does not fire when values are equal")
  func testIntOverloadNoFireOnEqual() {
    let bean     = SomeInt(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)
    support.firePropertyChange("n", 5, 5)
    #expect(recorder.events.isEmpty)
  }

  @Test("Int overload fires when values differ")
  func testIntOverloadFires() {
    let bean     = SomeInt(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)
    support.firePropertyChange("n", 1, 2)
    #expect(recorder.events.count == 1)
    #expect(recorder.events[0].getPropertyName() == "n")
  }

  @Test("Bool overload does not fire when values are equal")
  func testBoolOverloadNoFireOnEqual() {
    let bean     = SomeShort(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)
    support.firePropertyChange("flag", true, true)
    #expect(recorder.events.isEmpty)
  }

  @Test("Bool overload fires when values differ")
  func testBoolOverloadFires() {
    let bean     = SomeLong(0)
    let support  = java.beans.PropertyChangeSupport(bean)
    let recorder = Recorder()
    support.addPropertyChangeListener(recorder)
    support.firePropertyChange("flag", false, true)
    #expect(recorder.events.count == 1)
  }

  @Test("getPropertyChangeListeners returns all registered listeners")
  func testGetListeners() {
    let bean    = SomeInt(0)
    let support = java.beans.PropertyChangeSupport(bean)
    let r1      = Recorder()
    let r2      = Recorder()
    support.addPropertyChangeListener(r1)
    support.addPropertyChangeListener("x", r2)
    #expect(support.getPropertyChangeListeners().count == 2)
    #expect(support.getPropertyChangeListeners("x").count == 1)
  }
}

// MARK: - VetoableChangeSupport / PropertyVetoException

struct JavApi_beans_VetoableChangeSupport_Tests {

  final class AcceptListener: java.beans.VetoableChangeListener {
    var calls = 0
    func vetoableChange(_ evt: java.beans.PropertyChangeEvent) throws { calls += 1 }
  }

  final class VetoListener: java.beans.VetoableChangeListener {
    func vetoableChange(_ evt: java.beans.PropertyChangeEvent) throws {
      throw java.beans.PropertyVetoException("nope", evt)
    }
  }

  final class RollbackRecorder: java.beans.VetoableChangeListener {
    var events: [java.beans.PropertyChangeEvent] = []
    func vetoableChange(_ evt: java.beans.PropertyChangeEvent) throws {
      events.append(evt)
    }
  }

  @Test("accepted change calls listener")
  func testAccepted() throws {
    let bean    = SomeInt(0)
    let support = java.beans.VetoableChangeSupport(bean)
    let accept  = AcceptListener()
    support.addVetoableChangeListener(accept)
    try support.fireVetoableChange("x", nil, nil)
    #expect(accept.calls == 1)
  }

  @Test("vetoed change throws PropertyVetoException")
  func testVetoed() {
    let bean    = SomeLong(0)
    let support = java.beans.VetoableChangeSupport(bean)
    support.addVetoableChangeListener(VetoListener())
    #expect(throws: java.beans.PropertyVetoException.self) {
      try support.fireVetoableChange("x", nil, nil)
    }
  }

  @Test("rollback notifies already-accepted listeners with swapped values")
  func testRollback() {
    let bean      = SomeShort(0)
    let support   = java.beans.VetoableChangeSupport(bean)
    let recorder  = RollbackRecorder()
    let old_      = SomeInt(10)
    let new_      = SomeInt(20)
    support.addVetoableChangeListener(recorder)       // gets notified, then rolled back
    support.addVetoableChangeListener(VetoListener()) // vetoes

    try? support.fireVetoableChange(
      java.beans.PropertyChangeEvent(bean, "x", old_, new_))

    // recorder receives two events: forward + rollback
    #expect(recorder.events.count == 2)
    #expect(recorder.events[0].getOldValue().map(ObjectIdentifier.init) == ObjectIdentifier(old_))
    #expect(recorder.events[0].getNewValue().map(ObjectIdentifier.init) == ObjectIdentifier(new_))
    #expect(recorder.events[1].getOldValue().map(ObjectIdentifier.init) == ObjectIdentifier(new_))  // swapped
    #expect(recorder.events[1].getNewValue().map(ObjectIdentifier.init) == ObjectIdentifier(old_))  // swapped
  }

  @Test("Int overload does not fire when values are equal")
  func testIntOverloadNoFire() throws {
    let bean    = SomeInt(0)
    let support = java.beans.VetoableChangeSupport(bean)
    let accept  = AcceptListener()
    support.addVetoableChangeListener(accept)
    try support.fireVetoableChange("n", 3, 3)
    #expect(accept.calls == 0)
  }

  @Test("PropertyVetoException carries the event")
  func testExceptionCarriesEvent() {
    let bean    = SomeLong(0)
    let support = java.beans.VetoableChangeSupport(bean)
    support.addVetoableChangeListener(VetoListener())
    do {
      try support.fireVetoableChange("x", nil, nil)
      Issue.record("Expected PropertyVetoException")
    } catch let e as java.beans.PropertyVetoException {
      #expect(e.getPropertyChangeEvent().getPropertyName() == "x")
    } catch {
      Issue.record("Wrong exception type: \(error)")
    }
  }
}
