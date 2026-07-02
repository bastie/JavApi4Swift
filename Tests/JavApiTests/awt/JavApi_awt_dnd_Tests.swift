/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - DnDConstants
// =============================================================================

@Suite("java.awt.dnd.DnDConstants")
struct JavApi_awt_dnd_DnDConstants_Tests {

  @Test("ACTION_NONE is 0")
  func actionNone() {
    #expect(java.awt.dnd.DnDConstants.ACTION_NONE == 0)
  }

  @Test("ACTION_COPY is 1")
  func actionCopy() {
    #expect(java.awt.dnd.DnDConstants.ACTION_COPY == 1)
  }

  @Test("ACTION_MOVE is 2")
  func actionMove() {
    #expect(java.awt.dnd.DnDConstants.ACTION_MOVE == 2)
  }

  @Test("ACTION_COPY_OR_MOVE is COPY | MOVE")
  func actionCopyOrMove() {
    #expect(java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE ==
            java.awt.dnd.DnDConstants.ACTION_COPY | java.awt.dnd.DnDConstants.ACTION_MOVE)
  }

  @Test("ACTION_LINK equals ACTION_REFERENCE")
  func actionLinkEqualsReference() {
    #expect(java.awt.dnd.DnDConstants.ACTION_LINK == java.awt.dnd.DnDConstants.ACTION_REFERENCE)
  }

  @Test("ACTION_LINK is non-zero and distinct from COPY/MOVE")
  func actionLinkDistinct() {
    #expect(java.awt.dnd.DnDConstants.ACTION_LINK != 0)
    #expect(java.awt.dnd.DnDConstants.ACTION_LINK != java.awt.dnd.DnDConstants.ACTION_COPY)
    #expect(java.awt.dnd.DnDConstants.ACTION_LINK != java.awt.dnd.DnDConstants.ACTION_MOVE)
  }
}

// =============================================================================
// MARK: - DragSource
// =============================================================================

@Suite("java.awt.dnd.DragSource")
struct JavApi_awt_dnd_DragSource_Tests {

  @Test("getDefaultDragSource returns an instance")
  func defaultDragSource() {
    let ds = java.awt.dnd.DragSource.getDefaultDragSource()
    #expect(ds is java.awt.dnd.DragSource)
  }

  @Test("getDefaultDragSource returns same instance on repeated calls")
  func defaultDragSourceSingleton() {
    let a = java.awt.dnd.DragSource.getDefaultDragSource()
    let b = java.awt.dnd.DragSource.getDefaultDragSource()
    #expect(a === b)
  }

  @Test("isDragImageSupported returns false in headless mode")
  func dragImageNotSupported() {
    #expect(java.awt.dnd.DragSource.isDragImageSupported() == false)
  }

  @Test("Default cursors are nil in headless mode")
  func defaultCursorsNil() {
    #expect(java.awt.dnd.DragSource.DefaultCopyDrop   == nil)
    #expect(java.awt.dnd.DragSource.DefaultMoveDrop   == nil)
    #expect(java.awt.dnd.DragSource.DefaultLinkDrop   == nil)
    #expect(java.awt.dnd.DragSource.DefaultCopyNoDrop == nil)
    #expect(java.awt.dnd.DragSource.DefaultMoveNoDrop == nil)
    #expect(java.awt.dnd.DragSource.DefaultLinkNoDrop == nil)
  }

  @Test("createDragGestureRecognizer returns a MouseDragGestureRecognizer")
  @MainActor
  func createRecognizer() {
    let ds = java.awt.dnd.DragSource()
    let comp = java.awt.Component()

    final class NoopListener: java.awt.dnd.DragGestureListener {
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) {}
    }

    let r = ds.createDragGestureRecognizer(
      java.awt.dnd.MouseDragGestureRecognizer.self,
      comp,
      java.awt.dnd.DnDConstants.ACTION_COPY,
      NoopListener()
    )
    #expect(r is java.awt.dnd.MouseDragGestureRecognizer)
  }
}

// =============================================================================
// MARK: - DropTarget
// =============================================================================

@Suite("java.awt.dnd.DropTarget")
struct JavApi_awt_dnd_DropTarget_Tests {

  @Test("Default DropTarget is active")
  func defaultActive() {
    let dt = java.awt.dnd.DropTarget()
    #expect(dt.isActive() == true)
  }

  @Test("Default actions are COPY_OR_MOVE")
  func defaultActions() {
    let dt = java.awt.dnd.DropTarget()
    #expect(dt.getDefaultActions() == java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
  }

  @Test("setActive toggles active state")
  func setActive() {
    let dt = java.awt.dnd.DropTarget()
    dt.setActive(false)
    #expect(dt.isActive() == false)
    dt.setActive(true)
    #expect(dt.isActive() == true)
  }

  @Test("setDefaultActions changes actions")
  func setDefaultActions() {
    let dt = java.awt.dnd.DropTarget()
    dt.setDefaultActions(java.awt.dnd.DnDConstants.ACTION_COPY)
    #expect(dt.getDefaultActions() == java.awt.dnd.DnDConstants.ACTION_COPY)
  }

  @Test("getDropTargetContext returns non-nil context")
  func dropTargetContext() {
    let dt = java.awt.dnd.DropTarget()
    let ctx = dt.getDropTargetContext()
    #expect(ctx.dropTarget === dt)
  }

  @Test("getComponent returns nil when no component set")
  func noComponent() {
    let dt = java.awt.dnd.DropTarget()
    #expect(dt.getComponent() == nil)
  }
}

// =============================================================================
// MARK: - DragSourceEvent hierarchy
// =============================================================================

@Suite("java.awt.dnd.DragSourceEvent")
@MainActor
struct JavApi_awt_dnd_DragSourceEvent_Tests {

  private func makeContext() -> java.awt.dnd.DragSourceContext {
    final class StubTransferable: java.awt.datatransfer.Transferable {
      func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] { [] }
      func isDataFlavorSupported(_ flavor: java.awt.datatransfer.DataFlavor) -> Bool { false }
      func getTransferData(_ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
        throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
      }
    }
    return java.awt.dnd.DragSourceContext(
      component: java.awt.Component(),
      transferable: StubTransferable()
    )
  }

  @Test("DragSourceEvent without location has locationSpecified == false")
  func noLocation() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DragSourceEvent(ctx)
    #expect(evt.locationSpecified == false)
    #expect(evt.getLocation() == nil)
  }

  @Test("DragSourceEvent with coordinates has correct location")
  func withLocation() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DragSourceEvent(ctx, 10, 20)
    #expect(evt.locationSpecified == true)
    #expect(evt.x == 10)
    #expect(evt.y == 20)
    let pt = evt.getLocation()
    #expect(pt?.x == 10)
    #expect(pt?.y == 20)
  }

  @Test("DragSourceDropEvent default: not successful, ACTION_NONE")
  func dropEventDefault() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DragSourceDropEvent(ctx)
    #expect(evt.getDropSuccess() == false)
    #expect(evt.getDropAction() == java.awt.dnd.DnDConstants.ACTION_NONE)
  }

  @Test("DragSourceDropEvent with success flag")
  func dropEventSuccess() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DragSourceDropEvent(ctx,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_COPY,
                                               success: true)
    #expect(evt.getDropSuccess() == true)
    #expect(evt.getDropAction() == java.awt.dnd.DnDConstants.ACTION_COPY)
  }

  @Test("DragSourceDragEvent carries drop action and target actions")
  func dragDragEvent() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DragSourceDragEvent(ctx,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_MOVE,
                                               action: java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE,
                                               modifiers: 0)
    #expect(evt.getUserAction()    == java.awt.dnd.DnDConstants.ACTION_MOVE)
    #expect(evt.getTargetActions() == java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
  }
}

// =============================================================================
// MARK: - DropTargetEvent hierarchy
// =============================================================================

@Suite("java.awt.dnd.DropTargetEvent")
struct JavApi_awt_dnd_DropTargetEvent_Tests {

  private func makeContext() -> java.awt.dnd.DropTargetContext {
    java.awt.dnd.DropTarget().getDropTargetContext()
  }

  @Test("DropTargetEvent holds its context")
  func holdsContext() {
    let ctx = makeContext()
    let evt = java.awt.dnd.DropTargetEvent(ctx)
    #expect(evt.getDropTargetContext() === ctx)
  }

  @Test("DropTargetDragEvent carries location and actions")
  func dragEvent() {
    let ctx = makeContext()
    let pt  = java.awt.Point(5, 15)
    let evt = java.awt.dnd.DropTargetDragEvent(ctx,
                                               cursorLocation: pt,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_COPY,
                                               srcActions: java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
    #expect(evt.getLocation().x == 5)
    #expect(evt.getLocation().y == 15)
    #expect(evt.getDropAction()    == java.awt.dnd.DnDConstants.ACTION_COPY)
    #expect(evt.getSourceActions() == java.awt.dnd.DnDConstants.ACTION_COPY_OR_MOVE)
  }

  @Test("DropTargetDropEvent default is not local transfer")
  func dropEventNotLocal() {
    let ctx = makeContext()
    let pt  = java.awt.Point(0, 0)
    let evt = java.awt.dnd.DropTargetDropEvent(ctx,
                                               cursorLocation: pt,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_MOVE,
                                               srcActions: java.awt.dnd.DnDConstants.ACTION_MOVE)
    #expect(evt.getIsLocalTransfer() == false)
    #expect(evt.getDropAction() == java.awt.dnd.DnDConstants.ACTION_MOVE)
  }

  @Test("DropTargetDropEvent local transfer flag")
  func dropEventLocal() {
    let ctx = makeContext()
    let pt  = java.awt.Point(0, 0)
    let evt = java.awt.dnd.DropTargetDropEvent(ctx,
                                               cursorLocation: pt,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_COPY,
                                               srcActions: java.awt.dnd.DnDConstants.ACTION_COPY,
                                               isLocal: true)
    #expect(evt.getIsLocalTransfer() == true)
  }

  @Test("acceptDrop / rejectDrop / dropComplete are no-ops (headless)")
  func noopMethods() {
    let ctx = makeContext()
    let pt  = java.awt.Point(0, 0)
    let evt = java.awt.dnd.DropTargetDropEvent(ctx,
                                               cursorLocation: pt,
                                               dropAction: java.awt.dnd.DnDConstants.ACTION_NONE,
                                               srcActions: java.awt.dnd.DnDConstants.ACTION_NONE)
    // Must not crash
    evt.acceptDrop(java.awt.dnd.DnDConstants.ACTION_COPY)
    evt.rejectDrop()
    evt.dropComplete(true)
  }
}

// =============================================================================
// MARK: - DragGestureRecognizer
// =============================================================================

@Suite("java.awt.dnd.DragGestureRecognizer")
struct JavApi_awt_dnd_DragGestureRecognizer_Tests {

  @Test("MouseDragGestureRecognizer holds dragSource and component")
  @MainActor
  func holdsReferences() {
    let ds   = java.awt.dnd.DragSource()
    let comp = java.awt.Component()
    let r    = java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: ds,
      component: comp,
      dragAction: java.awt.dnd.DnDConstants.ACTION_COPY
    )
    #expect(r.dragSource === ds)
    #expect(r.component  === comp)
    #expect(r.sourceActions == java.awt.dnd.DnDConstants.ACTION_COPY)
  }

  @Test("fireDragGestureRecognized notifies added listener")
  @MainActor
  func firesListener() {
    let ds   = java.awt.dnd.DragSource()
    let comp = java.awt.Component()
    let r    = java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: ds,
      component: comp,
      dragAction: java.awt.dnd.DnDConstants.ACTION_COPY
    )

    var fired = false
    final class Listener: java.awt.dnd.DragGestureListener {
      var onGesture: () -> Void
      init(_ block: @escaping () -> Void) { onGesture = block }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { onGesture() }
    }

    r.addDragGestureListener(Listener { fired = true })
    r.fireDragGestureRecognized(action: java.awt.dnd.DnDConstants.ACTION_COPY,
                                origin: java.awt.Point(0, 0))
    #expect(fired == true)
  }

  @Test("registerListeners and unregisterListeners are no-ops (headless)")
  @MainActor
  func noopListeners() {
    let r = java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: java.awt.dnd.DragSource(),
      component: java.awt.Component(),
      dragAction: java.awt.dnd.DnDConstants.ACTION_COPY
    )
    // Must not crash
    r.registerListeners()
    r.unregisterListeners()
    r.resetRecognizer()
  }
}

// =============================================================================
// MARK: - DragSourceContext
// =============================================================================

@Suite("java.awt.dnd.DragSourceContext")
@MainActor
struct JavApi_awt_dnd_DragSourceContext_Tests {

  private func makeTransferable() -> any java.awt.datatransfer.Transferable {
    final class Stub: java.awt.datatransfer.Transferable {
      func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] { [] }
      func isDataFlavorSupported(_ flavor: java.awt.datatransfer.DataFlavor) -> Bool { false }
      func getTransferData(_ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
        throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
      }
    }
    return Stub()
  }

  @Test("getCursor returns default cursor")
  func defaultCursor() {
    let ctx = java.awt.dnd.DragSourceContext(
      component: java.awt.Component(),
      transferable: makeTransferable()
    )
    let cursor = ctx.getCursor()
    #expect(cursor.getType() == java.awt.Cursor.DEFAULT_CURSOR)
  }

  @Test("setCursor is a no-op (headless)")
  func setCursorNoOp() {
    let ctx = java.awt.dnd.DragSourceContext(
      component: java.awt.Component(),
      transferable: makeTransferable()
    )
    ctx.setCursor(nil) // must not crash
  }

  @Test("transferData returns nil (headless)")
  func transferDataNil() throws {
    let ctx = java.awt.dnd.DragSourceContext(
      component: java.awt.Component(),
      transferable: makeTransferable()
    )
    let result: Any? = try ctx.transferData(java.awt.datatransfer.DataFlavor.stringFlavor)
    #expect(result == nil)
  }
}

// =============================================================================
// MARK: - Step 1: DragSource.getDragThreshold (Java 1.4)
// =============================================================================

@Suite("java.awt.dnd.DragSource — getDragThreshold")
struct JavApi_awt_dnd_DragThreshold_Tests {

  @Test("getDragThreshold returns positive value")
  func thresholdPositive() {
    #expect(java.awt.dnd.DragSource.getDragThreshold() > 0)
  }

  @Test("getDragThreshold returns 5 (universal default)")
  func thresholdValue() {
    #expect(java.awt.dnd.DragSource.getDragThreshold() == 5)
  }
}

// =============================================================================
// MARK: - Step 1: MouseDragGestureRecognizer gesture detection
// =============================================================================

@Suite("java.awt.dnd.MouseDragGestureRecognizer — gesture detection")
@MainActor
struct JavApi_awt_dnd_GestureDetection_Tests {

  private func makeRecognizer(action: Int = java.awt.dnd.DnDConstants.ACTION_COPY)
    -> java.awt.dnd.MouseDragGestureRecognizer
  {
    java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: java.awt.dnd.DragSource(),
      component:  java.awt.Component(),
      dragAction: action
    )
  }

  @Test("No gesture fired when drag distance is below threshold")
  func belowThreshold() {
    let r = makeRecognizer()
    var fired = false
    final class L: java.awt.dnd.DragGestureListener {
      var onGesture: () -> Void
      init(_ b: @escaping () -> Void) { onGesture = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { onGesture() }
    }
    r.addDragGestureListener(L { fired = true })

    r.simulateMousePress(100, 100)
    // Move exactly at threshold — must NOT fire (> not >=)
    r.simulateMouseDrag(100 + java.awt.dnd.DragSource.getDragThreshold(), 100)
    #expect(fired == false)
  }

  @Test("Gesture fires when horizontal distance exceeds threshold")
  func horizontalExceedsThreshold() {
    let r = makeRecognizer()
    var firedCount = 0
    final class L: java.awt.dnd.DragGestureListener {
      var count: () -> Void
      init(_ b: @escaping () -> Void) { count = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { count() }
    }
    r.addDragGestureListener(L { firedCount += 1 })

    r.simulateMousePress(50, 50)
    r.simulateMouseDrag(50 + java.awt.dnd.DragSource.getDragThreshold() + 1, 50)
    #expect(firedCount == 1)
  }

  @Test("Gesture fires when vertical distance exceeds threshold")
  func verticalExceedsThreshold() {
    let r = makeRecognizer()
    var fired = false
    final class L: java.awt.dnd.DragGestureListener {
      var onGesture: () -> Void
      init(_ b: @escaping () -> Void) { onGesture = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { onGesture() }
    }
    r.addDragGestureListener(L { fired = true })

    r.simulateMousePress(50, 50)
    r.simulateMouseDrag(50, 50 + java.awt.dnd.DragSource.getDragThreshold() + 1)
    #expect(fired == true)
  }

  @Test("Gesture fires only once per press–drag sequence")
  func firesOnlyOnce() {
    let r = makeRecognizer()
    var firedCount = 0
    final class L: java.awt.dnd.DragGestureListener {
      var count: () -> Void
      init(_ b: @escaping () -> Void) { count = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { count() }
    }
    r.addDragGestureListener(L { firedCount += 1 })

    let t = java.awt.dnd.DragSource.getDragThreshold() + 2
    r.simulateMousePress(0, 0)
    r.simulateMouseDrag(t, 0)     // fires
    r.simulateMouseDrag(t + 10, 0) // must NOT fire again
    r.simulateMouseDrag(t + 20, 0)
    #expect(firedCount == 1)
  }

  @Test("After release, new press–drag sequence can fire again")
  func refireAfterRelease() {
    let r = makeRecognizer()
    var firedCount = 0
    final class L: java.awt.dnd.DragGestureListener {
      var count: () -> Void
      init(_ b: @escaping () -> Void) { count = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { count() }
    }
    r.addDragGestureListener(L { firedCount += 1 })

    let t = java.awt.dnd.DragSource.getDragThreshold() + 2
    r.simulateMousePress(0, 0)
    r.simulateMouseDrag(t, 0)      // first gesture
    r.simulateMouseRelease()

    r.simulateMousePress(100, 100)
    r.simulateMouseDrag(100 + t, 100) // second gesture
    #expect(firedCount == 2)
  }

  @Test("DragGestureEvent origin matches press coordinates")
  func originMatchesPressCoordinates() {
    let r = makeRecognizer()
    var origin: java.awt.Point? = nil
    final class L: java.awt.dnd.DragGestureListener {
      var capture: (java.awt.Point) -> Void
      init(_ b: @escaping (java.awt.Point) -> Void) { capture = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) {
        capture(dge.getDragOrigin())
      }
    }
    r.addDragGestureListener(L { origin = $0 })

    r.simulateMousePress(42, 17)
    r.simulateMouseDrag(42 + java.awt.dnd.DragSource.getDragThreshold() + 1, 17)
    #expect(origin?.x == 42)
    #expect(origin?.y == 17)
  }

  @Test("No gesture fired when not tracking (no prior press)")
  func noGestureWithoutPress() {
    let r = makeRecognizer()
    var fired = false
    final class L: java.awt.dnd.DragGestureListener {
      var onGesture: () -> Void
      init(_ b: @escaping () -> Void) { onGesture = b }
      func dragGestureRecognized(_ dge: java.awt.dnd.DragGestureEvent) { onGesture() }
    }
    r.addDragGestureListener(L { fired = true })

    // Drag without a prior press — must not fire
    r.simulateMouseDrag(100, 100)
    #expect(fired == false)
  }
}

// =============================================================================
// MARK: - Step 1: DragSource.startDrag fires dragDropEnd listener
// =============================================================================

@Suite("java.awt.dnd.DragSource — startDrag")
@MainActor
struct JavApi_awt_dnd_StartDrag_Tests {

  private func makeTransferable() -> any java.awt.datatransfer.Transferable {
    final class Stub: java.awt.datatransfer.Transferable {
      func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] { [] }
      func isDataFlavorSupported(_ flavor: java.awt.datatransfer.DataFlavor) -> Bool { false }
      func getTransferData(_ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
        throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
      }
    }
    return Stub()
  }

  @Test("startDrag notifies DragSourceListener with dragDropEnd (headless: not successful)")
  func startDragNotifiesListener() {
    let ds   = java.awt.dnd.DragSource()
    let comp = java.awt.Component()
    let recognizer = java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: ds, component: comp,
      dragAction: java.awt.dnd.DnDConstants.ACTION_COPY
    )
    let origin = java.awt.Point(10, 20)
    let trigger = java.awt.dnd.DragGestureEvent(recognizer,
                                                dragAction: java.awt.dnd.DnDConstants.ACTION_COPY,
                                                origin: origin)
    var dragDropEndCalled = false
    var successValue: Bool? = nil

    final class Listener: java.awt.dnd.DragSourceListener {
      var onEnd: (Bool) -> Void
      init(_ b: @escaping (Bool) -> Void) { onEnd = b }
      func dragEnter(_ dsde: java.awt.dnd.DragSourceDragEvent) {}
      func dragOver(_ dsde: java.awt.dnd.DragSourceDragEvent) {}
      func dropActionChanged(_ dsde: java.awt.dnd.DragSourceDragEvent) {}
      func dragExit(_ dse: java.awt.dnd.DragSourceEvent) {}
      func dragDropEnd(_ dsde: java.awt.dnd.DragSourceDropEvent) { onEnd(dsde.getDropSuccess()) }
    }

    let listener = Listener { success in
      dragDropEndCalled = true
      successValue = success
    }

    ds.startDrag(trigger: trigger, dragCursor: nil, transferable: makeTransferable(), dsl: listener)
    #expect(dragDropEndCalled == true)
    #expect(successValue == false)  // headless: drop never succeeds
  }

  @Test("startDrag does not crash without listener")
  func startDragWithoutListener() {
    let ds   = java.awt.dnd.DragSource()
    let comp = java.awt.Component()
    let r    = java.awt.dnd.MouseDragGestureRecognizer(
      dragSource: ds, component: comp,
      dragAction: java.awt.dnd.DnDConstants.ACTION_COPY
    )
    let trigger = java.awt.dnd.DragGestureEvent(r,
                                                dragAction: java.awt.dnd.DnDConstants.ACTION_COPY,
                                                origin: java.awt.Point(0, 0))
    // Must not crash
    ds.startDrag(trigger: trigger, dragCursor: nil, transferable: makeTransferable())
  }
}
