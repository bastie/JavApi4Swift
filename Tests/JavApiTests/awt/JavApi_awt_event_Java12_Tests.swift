/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - AWTEventListener
// =============================================================================

@Suite("java.awt.event.AWTEventListener")
struct JavApi_awt_event_AWTEventListener_Tests {

  @MainActor
  private final class RecordingListener: java.awt.event.AWTEventListener {
    private(set) var received: [java.awt.AWTEvent] = []
    func eventDispatched(_ event: java.awt.AWTEvent) {
      received.append(event)
    }
  }

  @Test("eventDispatched receives the forwarded event")
  @MainActor
  func eventDispatched() {
    let listener = RecordingListener()
    let comp  = java.awt.Component()
    let event = java.awt.event.ComponentEvent(comp, java.awt.event.ComponentEvent.COMPONENT_MOVED)

    listener.eventDispatched(event)

    #expect(listener.received.count == 1)
    #expect(listener.received.first === event)
  }
}

// =============================================================================
// MARK: - InputMethodEvent
// =============================================================================

@Suite("java.awt.event.InputMethodEvent")
struct JavApi_awt_event_InputMethodEvent_Tests {

  @Test("Event id constants have expected values")
  func idConstants() {
    #expect(java.awt.event.InputMethodEvent.INPUT_METHOD_FIRST        == 1100)
    #expect(java.awt.event.InputMethodEvent.INPUT_METHOD_TEXT_CHANGED == 1100)
    #expect(java.awt.event.InputMethodEvent.CARET_POSITION_CHANGED    == 1101)
    #expect(java.awt.event.InputMethodEvent.INPUT_METHOD_LAST         == 1101)
  }

  @Test("Caret-only convenience constructor sets committedCharacterCount to 0")
  @MainActor
  func caretOnlyConstructor() {
    let comp  = java.awt.Component()
    let caret = java.awt.font.TextHitInfo.leading(0)
    let event = java.awt.event.InputMethodEvent(
      comp, java.awt.event.InputMethodEvent.CARET_POSITION_CHANGED, caret, nil)

    #expect(event.getCommittedCharacterCount() == 0)
    #expect(event.getText() == nil)
    #expect(event.getCaret()?.charIndex == 0)
  }

  @Test("Full constructor round-trips committedCharacterCount")
  @MainActor
  func fullConstructor() {
    let comp = java.awt.Component()
    let event = java.awt.event.InputMethodEvent(
      comp, java.awt.event.InputMethodEvent.INPUT_METHOD_TEXT_CHANGED,
      nil, 3, nil, nil)

    #expect(event.getCommittedCharacterCount() == 3)
  }

  @Test("consume() marks the event as consumed")
  @MainActor
  func consume() {
    let comp = java.awt.Component()
    let event = java.awt.event.InputMethodEvent(
      comp, java.awt.event.InputMethodEvent.CARET_POSITION_CHANGED, nil, nil)

    #expect(event.isConsumed() == false)
    event.consume()
    #expect(event.isConsumed() == true)
  }
}

// =============================================================================
// MARK: - InvocationEvent
// =============================================================================

@Suite("java.awt.event.InvocationEvent")
struct JavApi_awt_event_InvocationEvent_Tests {

  private final class RecordingRunnable: Runnable {
    typealias Runnable = RecordingRunnable
    private(set) var didRun = false
    func run() { didRun = true }
  }

  @Test("Event id constants have expected values")
  func idConstants() {
    #expect(java.awt.event.InvocationEvent.INVOCATION_FIRST   == 1200)
    #expect(java.awt.event.InvocationEvent.INVOCATION_DEFAULT == 1200)
    #expect(java.awt.event.InvocationEvent.INVOCATION_LAST    == 1200)
  }

  @Test("dispatch() runs the wrapped Runnable")
  @MainActor
  func dispatchRunsRunnable() {
    let comp = java.awt.Component()
    let task = RecordingRunnable()
    let event = java.awt.event.InvocationEvent(comp, task)

    #expect(task.didRun == false)
    #expect(event.isDispatched() == false)

    event.dispatch()

    #expect(task.didRun == true)
    #expect(event.isDispatched() == true)
  }

  @Test("getWhen() returns a positive epoch-millis timestamp")
  @MainActor
  func getWhen() {
    let comp  = java.awt.Component()
    let task  = RecordingRunnable()
    let event = java.awt.event.InvocationEvent(comp, task)

    #expect(event.getWhen() > 0)
  }

  @Test("Notifier constructor stores catchThrowables without affecting dispatch")
  @MainActor
  func notifierConstructor() {
    let comp  = java.awt.Component()
    let task  = RecordingRunnable()
    let event = java.awt.event.InvocationEvent(comp, task, nil, true)

    event.dispatch()
    #expect(task.didRun == true)
    #expect(event.getException() == nil)
  }
}
