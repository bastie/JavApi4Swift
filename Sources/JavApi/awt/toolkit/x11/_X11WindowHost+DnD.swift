/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)

// =============================================================================
// MARK: XDND-Atom-Konstanten (Version 5)
// =============================================================================
//
// Alle Atoms werden beim ersten DnD-Aufruf via XInternAtom aufgelöst und
// im Atom-Cache von _X11WindowHost gespeichert.

// XDND ClientMessage-Datenformat: 32-Bit-Longs, 5 Elemente (l[0]…l[4])
// Offset im rohen XClientMessageEvent-Puffer (64-Bit Linux):
//   type(4)+pad(4)+serial(8)+send_event(4)+pad(4)+display*(8)+window(8)
//   +message_type(8)+format(4)+pad(4)+data.l[0](8)…
// → message_type bei Offset 40, format bei 48, data.l[0] bei 56
private let _xdndMsgDataOffset = 56   // Offset von data.l[0] im XEvent-Puffer

// XDND-Protokollversion
private let _xdndVersion: UInt = 5

// XDND-Aktions-Bits (für XdndActionCopy etc. — wir nutzen die Atom-Werte)
// Java-DnD-Aktionen
private let _xdndJavaCopy: Int = java.awt.dnd.DnDConstants.ACTION_COPY
private let _xdndJavaMove: Int = java.awt.dnd.DnDConstants.ACTION_MOVE
private let _xdndJavaLink: Int = java.awt.dnd.DnDConstants.ACTION_LINK
private let _xdndJavaNone: Int = java.awt.dnd.DnDConstants.ACTION_NONE

// XEvent-Puffer-Konstante (kompatibel mit _X11WindowHost)
private let _xdndEventBufSize = 512

// =============================================================================
// MARK: XDND-Drag-Zustandsmaschine
// =============================================================================

/// Zustand einer laufenden XDND-Drag-Session.
@MainActor
final class _XDNDDragState {

  /// Das Quell-X11-Fenster (unseres).
  let sourceXWin: X11WindowID

  /// Die zu übertragende Daten-Quelle.
  let transferable: any java.awt.datatransfer.Transferable

  /// Java-DnD-Quellaktion (ACTION_COPY | ACTION_MOVE | …).
  let dragAction: Int

  /// Optionaler `DragSourceListener`.
  weak var dsl: (any java.awt.dnd.DragSourceListener)?

  /// Das AWT-Quell-Komponente.
  let sourceComponent: java.awt.Component

  /// Aktuelles Ziel-X11-Fenster (das Fenster unter dem Cursor).
  var targetXWin: X11WindowID = 0

  /// Ob das Ziel XDND unterstützt (XdndAware gesetzt).
  var targetAcceptsXdnd: Bool = false

  /// Aktion, die das Ziel zuletzt per XdndStatus gemeldet hat.
  var targetAction: Int = _xdndJavaNone

  /// Ob das Ziel derzeit akzeptiert (true = XdndStatus mit accepted=1).
  var targetAccepted: Bool = false

  /// Zeitstempel des letzten XdndPosition.
  var lastTimestamp: UInt = 0

  init(sourceXWin: X11WindowID,
       transferable: any java.awt.datatransfer.Transferable,
       dragAction: Int,
       dsl: (any java.awt.dnd.DragSourceListener)?,
       sourceComponent: java.awt.Component) {
    self.sourceXWin      = sourceXWin
    self.transferable    = transferable
    self.dragAction      = dragAction
    self.dsl             = dsl
    self.sourceComponent = sourceComponent
  }
}

// =============================================================================
// MARK: _X11WindowHost DnD Extension
// =============================================================================

extension _X11WindowHost {

  // ---------------------------------------------------------------------------
  // MARK: XDND-Atom-Cache (intern per _xdndAtoms)
  // ---------------------------------------------------------------------------

  /// Lädt alle XDND-Atoms auf einmal.
  /// Muss auf dem Main-Thread aufgerufen werden (nach openDisplay).
  @MainActor
  func _xdndLoadAtoms() {
    guard let dpy = currentDisplay, let fnAtom = _fnInternAtom else { return }
    if _atomXdndAware != 0 { return }   // bereits geladen

    func atom(_ name: String) -> UInt {
      name.withCString { fnAtom(dpy, $0, 0) }
    }
    _atomXdndAware       = atom("XdndAware")
    _atomXdndEnter       = atom("XdndEnter")
    _atomXdndPosition    = atom("XdndPosition")
    _atomXdndStatus      = atom("XdndStatus")
    _atomXdndLeave       = atom("XdndLeave")
    _atomXdndDrop        = atom("XdndDrop")
    _atomXdndFinished    = atom("XdndFinished")
    _atomXdndSelection   = atom("XdndSelection")
    _atomXdndActionCopy  = atom("XdndActionCopy")
    _atomXdndActionMove  = atom("XdndActionMove")
    _atomXdndActionLink  = atom("XdndActionLink")
    _atomXdndActionList  = atom("XdndActionList")
    _atomXdndTypeList    = atom("XdndTypeList")
    _atomUTF8String      = atom("UTF8_STRING")
    _atomText            = atom("TEXT")
    _atomXdndProperty    = atom("XdndDropProperty")
  }

  // ---------------------------------------------------------------------------
  // MARK: XdndAware auf Fenster setzen
  // ---------------------------------------------------------------------------

  /// Setzt die `XdndAware`-Eigenschaft auf `xwin`, damit andere Anwendungen
  /// wissen, dass dieses Fenster XDND Version 5 unterstützt.
  @MainActor
  func _xdndRegisterWindow(_ xwin: X11WindowID) {
    guard let dpy = currentDisplay,
          let fnProp = _fnChangeProperty else { return }
    _xdndLoadAtoms()
    guard _atomXdndAware != 0 else { return }

    // XdndAware = CARD32-Eigenschaft mit dem XDND-Protokoll-Versionswert.
    // XA_ATOM = 4, PropModeReplace = 0, 32-Bit-Format.
    var version = _xdndVersion
    withUnsafeBytes(of: &version) { vBytes in
      _ = fnProp(dpy, xwin,
                 _atomXdndAware,
                 4 /* XA_ATOM */,
                 32,                          // format
                 0 /* PropModeReplace */,
                 vBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                 1)                           // 1 Element
    }
  }

  // ---------------------------------------------------------------------------
  // MARK: Drag starten (Einstiegspunkt von _X11MouseDragGestureRecognizer)
  // ---------------------------------------------------------------------------

  /// Startet eine XDND-Drag-Session vom Quell-Komponent `from`.
  ///
  /// Speichert den Drag-Zustand; der laufende X11-EventLoop übernimmt
  /// ab sofort die Weiterleitung von MotionNotify- und ButtonRelease-Events
  /// an `_xdndHandleMotion` / `_xdndHandleRelease`.
  @MainActor
  func _xdndBeginDrag(
    from component: java.awt.Component,
    transferable: any java.awt.datatransfer.Transferable,
    dragAction: Int,
    dsl: (any java.awt.dnd.DragSourceListener)?
  ) {
    _xdndLoadAtoms()

    // Quell-X11-Fenster ermitteln
    var node: java.awt.Component? = component
    while let n = node {
      if let win = n as? java.awt.Window,
         let xwin = _reverseRegistryLookup(win) {
        _xdndDragState = _XDNDDragState(
          sourceXWin:      xwin,
          transferable:    transferable,
          dragAction:      dragAction,
          dsl:             dsl,
          sourceComponent: component)
        return
      }
      node = n.parent
    }
    // Kein X11-Fenster gefunden → Drag ignorieren
  }

  /// Liefert die X11-Window-ID für ein AWT-Fenster (Thread-sicher via Main-Thread).
  @MainActor
  func _reverseRegistryLookup(_ window: java.awt.Window) -> X11WindowID? {
    _x11ReverseRegistry[ObjectIdentifier(window)]
  }

  // ---------------------------------------------------------------------------
  // MARK: Drag-Motion-Handler (aus _dispatchEvent → X11_MotionNotify)
  // ---------------------------------------------------------------------------

  /// Wird aus `_dispatchEvent` für `X11_MotionNotify` aufgerufen, wenn ein
  /// Drag aktiv ist (Taste gedrückt + _xdndDragState gesetzt).
  @MainActor
  func _xdndHandleMotion(rootX: Int, rootY: Int, timestamp: UInt) {
    guard let state = _xdndDragState,
          let dpy = currentDisplay else { return }

    // Fenster unter dem Cursor bestimmen
    let (targetWin, _) = _xdndWindowAtRoot(x: rootX, y: rootY)

    if targetWin != state.targetXWin {
      // Fenster gewechselt — ggf. XdndLeave an altes Ziel senden
      if state.targetXWin != 0 && state.targetAcceptsXdnd {
        _xdndSendLeave(dpy: dpy, state: state)
      }

      state.targetXWin = targetWin

      // Prüfen, ob neues Fenster XDND unterstützt
      state.targetAcceptsXdnd = _xdndCheckAware(dpy: dpy, xwin: targetWin)
      state.targetAccepted    = false
      state.targetAction      = _xdndJavaNone

      if state.targetAcceptsXdnd {
        _xdndSendEnter(dpy: dpy, state: state)
      }

      // Intra-App: AWT-DropTarget im neuen Fenster benachrichtigen
      _xdndIntraAppEnter(state: state, rootX: rootX, rootY: rootY)
    }

    state.lastTimestamp = timestamp

    if state.targetAcceptsXdnd {
      _xdndSendPosition(dpy: dpy, state: state, rootX: rootX, rootY: rootY, timestamp: timestamp)
    }

    // Intra-App Drag-Over
    _xdndIntraAppOver(state: state, rootX: rootX, rootY: rootY)
  }

  // ---------------------------------------------------------------------------
  // MARK: Drop-Handler (aus _dispatchEvent → X11_ButtonRelease)
  // ---------------------------------------------------------------------------

  /// Wird aus `_dispatchEvent` für `X11_ButtonRelease` aufgerufen, wenn ein
  /// XDND-Drag aktiv war.
  @MainActor
  func _xdndHandleRelease(rootX: Int, rootY: Int, timestamp: UInt) {
    guard let state = _xdndDragState,
          let dpy = currentDisplay else { return }
    _xdndDragState = nil

    let success: Bool
    if state.targetAcceptsXdnd && state.targetAccepted {
      // Cross-App Drop
      _xdndSendDrop(dpy: dpy, state: state, timestamp: timestamp)
      success = true
    } else {
      // Intra-App Drop
      success = _xdndIntraAppDrop(state: state, rootX: rootX, rootY: rootY)
      if state.targetXWin != 0 && state.targetAcceptsXdnd {
        _xdndSendLeave(dpy: dpy, state: state)
      }
    }

    // DragSourceDropEvent feuern
    let action = success ? state.dragAction : _xdndJavaNone
    let ctx    = java.awt.dnd.DragSourceContext(component: state.sourceComponent,
                                                transferable: state.transferable)
    if let dsl = state.dsl { ctx.addDragSourceListener(dsl) }
    let evt = java.awt.dnd.DragSourceDropEvent(ctx, dropAction: action, success: success)
    state.dsl?.dragDropEnd(evt)
  }

  // ---------------------------------------------------------------------------
  // MARK: XDND ClientMessage-Handler (aus _dispatchEvent → X11_ClientMessage)
  // ---------------------------------------------------------------------------

  /// Verarbeitet eingehende XDND ClientMessages (als Drop-Ziel).
  /// Gibt `true` zurück, wenn die Nachricht behandelt wurde.
  @MainActor
  func _xdndHandleClientMessage(buf: UnsafeMutableRawPointer,
                                 xwin: X11WindowID,
                                 awtWindow: java.awt.Window) -> Bool {
    guard let dpy = currentDisplay else { return false }
    _xdndLoadAtoms()

    // message_type liegt bei Offset 40 im XClientMessageEvent-Puffer
    let msgType = buf.load(fromByteOffset: 40, as: UInt.self)

    // Daten: data.l[0]…[4] bei Offsets 56, 64, 72, 80, 88
    func dataL(_ i: Int) -> UInt {
      buf.load(fromByteOffset: _xdndMsgDataOffset + i * 8, as: UInt.self)
    }

    if msgType == _atomXdndEnter {
      // XdndEnter: Drag tritt ins Fenster ein
      // data.l[0] = Quell-Window, data.l[1] bit0 = more types, bits24-31 = version
      let sourceWin = dataL(0)
      _xdndPendingSource    = sourceWin
      _xdndPendingTimestamp = 0
      return true

    } else if msgType == _atomXdndPosition {
      // XdndPosition: Drag-Cursor-Position aktualisiert
      // data.l[0] = Quell-Window
      // data.l[2] = (rootX << 16) | rootY
      // data.l[3] = Zeitstempel
      // data.l[4] = vorgeschlagene Aktion
      let sourceWin  = dataL(0)
      let coordPacked = dataL(2)
      let rootX = Int((coordPacked >> 16) & 0xFFFF)
      let rootY = Int(coordPacked & 0xFFFF)
      let timestamp  = dataL(3)
      let actionAtom = dataL(4)
      _xdndPendingTimestamp = timestamp

      // Root-Koordinaten in Fenster-lokale Koordinaten umrechnen
      let (localX, localY) = _xdndRootToWindow(xwin: xwin, rootX: rootX, rootY: rootY)
      // Letzte Position für XdndDrop merken
      _xdndDropLocalX = localX
      _xdndDropLocalY = localY

      // Java-DropTarget benachrichtigen
      let javaAction = _xdndAtomToJavaAction(actionAtom)
      let accepted   = _xdndDispatchDragOver(awtWindow: awtWindow,
                                              x: localX, y: localY,
                                              sourceActions: state_dragAction(sourceWin),
                                              dropAction: javaAction)

      // XdndStatus zurücksenden
      _xdndSendStatus(dpy: dpy, targetWin: xwin, sourceWin: sourceWin,
                      accepted: accepted, action: accepted ? actionAtom : 0)
      return true

    } else if msgType == _atomXdndLeave {
      // XdndLeave: Drag hat Fenster verlassen
      _xdndDispatchDragExit(awtWindow: awtWindow, x: 0, y: 0)
      _xdndPendingSource    = 0
      _xdndPendingTimestamp = 0
      return true

    } else if msgType == _atomXdndDrop {
      // XdndDrop: Drop auf diesem Fenster
      let sourceWin = dataL(0)
      let timestamp = dataL(2)

      // Daten per XConvertSelection anfordern
      if let fnConv = _fnConvertSelection, _atomXdndSelection != 0 {
        _ = fnConv(dpy, _atomXdndSelection, _atomUTF8String,
                   _atomXdndProperty, xwin, timestamp)
        _ = fnFlushX11?(dpy)
        _xdndDropSourceWin = sourceWin
        _xdndDropTargetWin = xwin
        _xdndDropTimestamp = timestamp
        _xdndDropAwtWindow = awtWindow
      } else {
        // Kein XConvertSelection — Drop direkt abschließen ohne Daten
        _xdndSendFinished(dpy: dpy, targetWin: xwin, sourceWin: sourceWin,
                          accepted: false, action: 0)
      }
      return true

    } else if msgType == _atomXdndFinished {
      // XdndFinished: Ziel hat unseren Drop verarbeitet (wir sind Quelle)
      // Nichts zu tun — dragDropEnd wurde bereits in _xdndHandleRelease gefeuert.
      return true

    } else if msgType == _atomXdndStatus {
      // XdndStatus: Rückmeldung vom Ziel an uns als Quelle
      // data.l[0] = Ziel-Window
      // data.l[1] bit0 = accepted
      // data.l[4] = Aktion
      guard let state = _xdndDragState else { return false }
      let accepted   = (dataL(1) & 1) != 0
      let actionAtom = dataL(4)
      state.targetAccepted = accepted
      state.targetAction   = _xdndAtomToJavaAction(actionAtom)
      return true
    }

    return false
  }

  // ---------------------------------------------------------------------------
  // MARK: SelectionNotify-Handler (Daten vom Fremd-Quell-Fenster empfangen)
  // ---------------------------------------------------------------------------

  /// Verarbeitet `SelectionNotify` — liefert die Transferdaten für einen
  /// Cross-App-Drop, den wir als Ziel empfangen haben.
  @MainActor
  func _xdndHandleSelectionNotify(buf: UnsafeMutableRawPointer) {
    // XSelectionEvent Layout (64-Bit Linux):
    //  0:type(4)  8:serial(8)  16:send_event(4)[+4]  24:display*(8)
    // 32:requestor(XID/8)  40:selection(8)  48:target(8)  56:property(8)
    // 64:time(8)
    let property  = buf.load(fromByteOffset: 56, as: UInt.self)
    let requestor = buf.load(fromByteOffset: 32, as: X11WindowID.self)

    guard property != 0,   // None = Konvertierung fehlgeschlagen
          let dpy = currentDisplay,
          let fnGetProp = _fnGetWindowProperty,
          let fnFree    = _fnXFreeWrapper else { return }

    var actualType:   UInt = 0
    var actualFormat: Int32 = 0
    var nItems:       UInt = 0
    var bytesAfter:   UInt = 0
    var propData: UnsafeMutablePointer<UInt8>? = nil

    let result = fnGetProp(dpy, requestor, property,
                           0, 65536,   // offset, length (in 32-Bit-Einheiten)
                           1,          // delete = true (bereinigen)
                           0,          // AnyPropertyType
                           &actualType, &actualFormat, &nItems, &bytesAfter,
                           &propData)

    defer { if let p = propData { fnFree(UnsafeMutableRawPointer(p)) } }

    guard result == 0 /* Success */, let rawData = propData, nItems > 0 else {
      // Konvertierung fehlgeschlagen — Drop abschließen ohne Daten
      if let dpy2 = currentDisplay, _xdndDropSourceWin != 0 {
        _xdndSendFinished(dpy: dpy2, targetWin: requestor,
                          sourceWin: _xdndDropSourceWin, accepted: false, action: 0)
      }
      _xdndClearDropState()
      return
    }

    // UTF-8-String aus Rohdaten
    let byteCount = Int(nItems) * (actualFormat == 16 ? 2 : (actualFormat == 32 ? 4 : 1))
    let str = String(bytes: UnsafeBufferPointer(start: rawData, count: byteCount),
                     encoding: .utf8) ?? ""

    // Transferable aufbauen und Drop dispatchen
    let t = _X11XDNDInboundTransferable(text: str)
    if let awtWin = _xdndDropAwtWindow {
      let accepted = _xdndDispatchDrop(awtWindow: awtWin,
                                       x: _xdndDropLocalX, y: _xdndDropLocalY,
                                       transferable: t,
                                       sourceActions: _xdndJavaCopy | _xdndJavaMove,
                                       dropAction: _xdndJavaCopy)
      // XdndFinished senden
      let actionAtom = _xdndJavaActionToAtom(_xdndJavaCopy)
      _xdndSendFinished(dpy: dpy, targetWin: requestor,
                        sourceWin: _xdndDropSourceWin,
                        accepted: accepted, action: actionAtom)
    }
    _xdndClearDropState()
  }

  // ---------------------------------------------------------------------------
  // MARK: SelectionRequest beantworten (wir sind Drag-Quelle)
  // ---------------------------------------------------------------------------

  /// Verarbeitet `SelectionRequest` — das Ziel-Fenster fragt unsere
  /// `XdndSelection`-Daten an.  Wir schreiben den Text als UTF-8 ins Property
  /// des Requestors und senden ein `SelectionNotify`.
  @MainActor
  func _xdndHandleSelectionRequest(buf: UnsafeMutableRawPointer) {
    guard let state = _xdndDragState,
          let dpy   = currentDisplay,
          let fnProp = _fnChangeProperty,
          let fnSend = _fnSendEvent else { return }

    // XSelectionRequestEvent Layout (64-Bit Linux):
    //  0:type(4)  8:serial(8)  16:send_event(4)[+4]  24:display*(8)
    // 32:owner(XID/8)  40:requestor(XID/8)  48:selection(8)
    // 56:target(8)  64:property(8)  72:time(8)
    let requestor = buf.load(fromByteOffset: 40, as: X11WindowID.self)
    let target    = buf.load(fromByteOffset: 56, as: UInt.self)
    let property  = buf.load(fromByteOffset: 64, as: UInt.self)
    let time      = buf.load(fromByteOffset: 72, as: UInt.self)

    // Nur UTF8_STRING und TEXT unterstützen
    guard property != 0,
          (target == _atomUTF8String || target == _atomText) else {
      // Antwort mit property = None (Konvertierung abgelehnt)
      _xdndSendSelectionNotify(dpy: dpy, fnSend: fnSend,
                               requestor: requestor, target: target,
                               property: 0, time: time)
      return
    }

    // Text aus Transferable
    let strFlavor = java.awt.datatransfer.DataFlavor.stringFlavor
    guard let raw = try? state.transferable.getTransferData(strFlavor),
          let str = raw as? String else {
      _xdndSendSelectionNotify(dpy: dpy, fnSend: fnSend,
                               requestor: requestor, target: target,
                               property: 0, time: time)
      return
    }

    // UTF-8 ins Property des Requestors schreiben
    let utf8 = Array(str.utf8)
    utf8.withUnsafeBufferPointer { buf in
      _ = fnProp(dpy, requestor, property,
                 _atomUTF8String, 8, 0 /* PropModeReplace */,
                 buf.baseAddress, Int32(utf8.count))
    }

    // SelectionNotify senden
    _xdndSendSelectionNotify(dpy: dpy, fnSend: fnSend,
                             requestor: requestor, target: target,
                             property: property, time: time)
    _ = fnFlushX11?(dpy)
  }

  /// Sendet ein `SelectionNotify`-Event an den Requestor.
  @MainActor
  private func _xdndSendSelectionNotify(dpy: X11DisplayPtr,
                                         fnSend: XSendEventFunc,
                                         requestor: X11WindowID,
                                         target: UInt,
                                         property: UInt,
                                         time: UInt) {
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    // XSelectionEvent type = 31 (SelectionNotify)
    eventBuf.storeBytes(of: Int32(31), toByteOffset: 0,  as: Int32.self)
    // requestor (offset 32)
    eventBuf.storeBytes(of: requestor, toByteOffset: 32, as: X11WindowID.self)
    // selection = XdndSelection (offset 40)
    eventBuf.storeBytes(of: _atomXdndSelection, toByteOffset: 40, as: UInt.self)
    // target (offset 48)
    eventBuf.storeBytes(of: target,    toByteOffset: 48, as: UInt.self)
    // property (offset 56)
    eventBuf.storeBytes(of: property,  toByteOffset: 56, as: UInt.self)
    // time (offset 64)
    eventBuf.storeBytes(of: time,      toByteOffset: 64, as: UInt.self)

    _ = fnSend(dpy, requestor, 0, 0, eventBuf)
  }

  // ---------------------------------------------------------------------------
  // MARK: Drag-over / Drop Dispatch (als Ziel)
  // ---------------------------------------------------------------------------

  @MainActor
  func _xdndDispatchDragOver(awtWindow: java.awt.Window,
                              x: Int, y: Int,
                              sourceActions: Int,
                              dropAction: Int) -> Bool {
    guard let hit = _hitTest(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget(),
          dt.isActive() else { return false }
    let ctx    = dt.getDropTargetContext()
    let origin = _absoluteOrigin(hit)
    let dtde   = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(x - origin.x, y - origin.y),
      dropAction: dropAction,
      srcActions: sourceActions)
    for l in dt._listenerArray { l.dragOver(dtde) }
    return true
  }

  @MainActor
  func _xdndDispatchDragExit(awtWindow: java.awt.Window, x: Int, y: Int) {
    // Alle aktiven DropTargets im Fenster benachrichtigen
    _xdndVisitDropTargets(in: awtWindow) { dt in
      let ctx = dt.getDropTargetContext()
      let dte = java.awt.dnd.DropTargetEvent(ctx)
      for l in dt._listenerArray { l.dragExit(dte) }
    }
  }

  @MainActor
  func _xdndDispatchDrop(awtWindow: java.awt.Window,
                          x: Int, y: Int,
                          transferable: any java.awt.datatransfer.Transferable,
                          sourceActions: Int,
                          dropAction: Int) -> Bool {
    guard let hit = _hitTest(x: x, y: y, in: awtWindow),
          let dt  = hit.getDropTarget(),
          dt.isActive() else { return false }
    let ctx    = dt.getDropTargetContext()
    let origin = _absoluteOrigin(hit)
    let dtde   = java.awt.dnd.DropTargetDropEvent(
      ctx,
      cursorLocation: java.awt.Point(x - origin.x, y - origin.y),
      dropAction: dropAction,
      srcActions: sourceActions,
      isLocal: false,
      transferable: transferable)
    var accepted = false
    for l in dt._listenerArray { l.drop(dtde); accepted = true }
    return accepted
  }

  // ---------------------------------------------------------------------------
  // MARK: Intra-App Helpers (Drag innerhalb derselben Anwendung)
  // ---------------------------------------------------------------------------

  @MainActor
  private func _xdndIntraAppEnter(state: _XDNDDragState, rootX: Int, rootY: Int) {
    // Ziel-AWT-Fenster anhand der Root-Koordinaten suchen
    guard let (awtWin, xwin) = _awtWindowAtRoot(rootX: rootX, rootY: rootY) else { return }
    let (lx, ly) = _xdndRootToWindow(xwin: xwin, rootX: rootX, rootY: rootY)
    let sourceActions = state.dragAction

    guard let hit = _hitTest(x: lx, y: ly, in: awtWin),
          let dt  = hit.getDropTarget(), dt.isActive() else { return }
    let ctx    = dt.getDropTargetContext()
    let origin = _absoluteOrigin(hit)
    let dtde   = java.awt.dnd.DropTargetDragEvent(
      ctx,
      cursorLocation: java.awt.Point(lx - origin.x, ly - origin.y),
      dropAction: sourceActions,
      srcActions: sourceActions)
    for l in dt._listenerArray { l.dragEnter(dtde) }
  }

  @MainActor
  private func _xdndIntraAppOver(state: _XDNDDragState, rootX: Int, rootY: Int) {
    guard let (awtWin, xwin) = _awtWindowAtRoot(rootX: rootX, rootY: rootY) else { return }
    let (lx, ly) = _xdndRootToWindow(xwin: xwin, rootX: rootX, rootY: rootY)
    _ = _xdndDispatchDragOver(awtWindow: awtWin, x: lx, y: ly,
                               sourceActions: state.dragAction,
                               dropAction: state.dragAction)
  }

  @MainActor
  private func _xdndIntraAppDrop(state: _XDNDDragState,
                                  rootX: Int, rootY: Int) -> Bool {
    guard let (awtWin, xwin) = _awtWindowAtRoot(rootX: rootX, rootY: rootY) else { return false }
    let (lx, ly) = _xdndRootToWindow(xwin: xwin, rootX: rootX, rootY: rootY)
    return _xdndDispatchDrop(awtWindow: awtWin, x: lx, y: ly,
                              transferable: state.transferable,
                              sourceActions: state.dragAction,
                              dropAction: state.dragAction)
  }

  // ---------------------------------------------------------------------------
  // MARK: XDND ClientMessage senden
  // ---------------------------------------------------------------------------

  @MainActor
  private func _xdndSendEnter(dpy: X11DisplayPtr, state: _XDNDDragState) {
    guard let fnSend = _fnSendEvent else { return }
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    // type = ClientMessage (33), format = 32
    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    // window = target (offset 32)
    eventBuf.storeBytes(of: state.targetXWin, toByteOffset: 32, as: X11WindowID.self)
    // message_type = XdndEnter (offset 40)
    eventBuf.storeBytes(of: _atomXdndEnter, toByteOffset: 40, as: UInt.self)
    // format = 32 (offset 48)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    // data.l[0] = source window (offset 56)
    eventBuf.storeBytes(of: state.sourceXWin, toByteOffset: 56, as: UInt.self)
    // data.l[1] = version << 24 (offset 64)
    let flags: UInt = (_xdndVersion << 24)
    eventBuf.storeBytes(of: flags, toByteOffset: 64, as: UInt.self)
    // data.l[2] = UTF8_STRING atom (offset 72)
    eventBuf.storeBytes(of: _atomUTF8String, toByteOffset: 72, as: UInt.self)

    _ = fnSend(dpy, state.targetXWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  @MainActor
  private func _xdndSendPosition(dpy: X11DisplayPtr, state: _XDNDDragState,
                                  rootX: Int, rootY: Int, timestamp: UInt) {
    guard let fnSend = _fnSendEvent else { return }
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    eventBuf.storeBytes(of: state.targetXWin, toByteOffset: 32, as: X11WindowID.self)
    eventBuf.storeBytes(of: _atomXdndPosition, toByteOffset: 40, as: UInt.self)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    // data.l[0] = source window
    eventBuf.storeBytes(of: state.sourceXWin, toByteOffset: 56, as: UInt.self)
    // data.l[2] = (rootX << 16) | rootY
    let coords: UInt = (UInt(rootX) << 16) | UInt(rootY & 0xFFFF)
    eventBuf.storeBytes(of: coords, toByteOffset: 72, as: UInt.self)
    // data.l[3] = timestamp
    eventBuf.storeBytes(of: timestamp, toByteOffset: 80, as: UInt.self)
    // data.l[4] = vorgeschlagene Aktion
    let actionAtom = _xdndJavaActionToAtom(state.dragAction)
    eventBuf.storeBytes(of: actionAtom, toByteOffset: 88, as: UInt.self)

    _ = fnSend(dpy, state.targetXWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  @MainActor
  private func _xdndSendLeave(dpy: X11DisplayPtr, state: _XDNDDragState) {
    guard let fnSend = _fnSendEvent else { return }
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    eventBuf.storeBytes(of: state.targetXWin, toByteOffset: 32, as: X11WindowID.self)
    eventBuf.storeBytes(of: _atomXdndLeave, toByteOffset: 40, as: UInt.self)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    eventBuf.storeBytes(of: state.sourceXWin, toByteOffset: 56, as: UInt.self)

    _ = fnSend(dpy, state.targetXWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  @MainActor
  private func _xdndSendDrop(dpy: X11DisplayPtr, state: _XDNDDragState,
                               timestamp: UInt) {
    guard let fnSend = _fnSendEvent else { return }

    // Wir werden Eigentümer der XdndSelection (damit das Ziel Daten holen kann)
    if let fnOwner = _fnSetSelectionOwner, _atomXdndSelection != 0 {
      _ = fnOwner(dpy, _atomXdndSelection, state.sourceXWin, timestamp)
    }

    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    eventBuf.storeBytes(of: state.targetXWin, toByteOffset: 32, as: X11WindowID.self)
    eventBuf.storeBytes(of: _atomXdndDrop, toByteOffset: 40, as: UInt.self)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    eventBuf.storeBytes(of: state.sourceXWin, toByteOffset: 56, as: UInt.self)
    eventBuf.storeBytes(of: timestamp, toByteOffset: 72, as: UInt.self)

    _ = fnSend(dpy, state.targetXWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  @MainActor
  private func _xdndSendStatus(dpy: X11DisplayPtr, targetWin: X11WindowID,
                                sourceWin: X11WindowID, accepted: Bool, action: UInt) {
    guard let fnSend = _fnSendEvent else { return }
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    eventBuf.storeBytes(of: sourceWin, toByteOffset: 32, as: X11WindowID.self)
    eventBuf.storeBytes(of: _atomXdndStatus, toByteOffset: 40, as: UInt.self)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    // data.l[0] = Ziel-Window
    eventBuf.storeBytes(of: targetWin, toByteOffset: 56, as: UInt.self)
    // data.l[1] = accepted flag (bit 0)
    let flags: UInt = accepted ? 1 : 0
    eventBuf.storeBytes(of: flags, toByteOffset: 64, as: UInt.self)
    // data.l[4] = Aktion
    eventBuf.storeBytes(of: action, toByteOffset: 88, as: UInt.self)

    _ = fnSend(dpy, sourceWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  @MainActor
  private func _xdndSendFinished(dpy: X11DisplayPtr, targetWin: X11WindowID,
                                  sourceWin: X11WindowID, accepted: Bool, action: UInt) {
    guard let fnSend = _fnSendEvent else { return }
    let eventBuf = UnsafeMutableRawPointer.allocate(byteCount: _xdndEventBufSize, alignment: 8)
    defer { eventBuf.deallocate() }
    eventBuf.initializeMemory(as: UInt8.self, repeating: 0, count: _xdndEventBufSize)

    eventBuf.storeBytes(of: Int32(33), toByteOffset: 0, as: Int32.self)
    eventBuf.storeBytes(of: sourceWin, toByteOffset: 32, as: X11WindowID.self)
    eventBuf.storeBytes(of: _atomXdndFinished, toByteOffset: 40, as: UInt.self)
    eventBuf.storeBytes(of: Int32(32), toByteOffset: 48, as: Int32.self)
    // data.l[0] = Ziel-Window
    eventBuf.storeBytes(of: targetWin, toByteOffset: 56, as: UInt.self)
    // data.l[1] = accepted flag
    let flags: UInt = accepted ? 1 : 0
    eventBuf.storeBytes(of: flags, toByteOffset: 64, as: UInt.self)
    // data.l[4] = Aktion
    eventBuf.storeBytes(of: action, toByteOffset: 88, as: UInt.self)

    _ = fnSend(dpy, sourceWin, 0, 0, eventBuf)
    _ = fnFlushX11?(dpy)
  }

  // ---------------------------------------------------------------------------
  // MARK: Hilfsfunktionen
  // ---------------------------------------------------------------------------

  /// Prüft, ob `xwin` XDND unterstützt (hat `XdndAware`-Eigenschaft).
  @MainActor
  private func _xdndCheckAware(dpy: X11DisplayPtr, xwin: X11WindowID) -> Bool {
    guard xwin != 0, let fnGetProp = _fnGetWindowProperty,
          let fnFree = _fnXFreeWrapper,
          _atomXdndAware != 0 else { return false }

    var actualType:   UInt = 0
    var actualFormat: Int32 = 0
    var nItems:       UInt = 0
    var bytesAfter:   UInt = 0
    var propData: UnsafeMutablePointer<UInt8>? = nil

    let result = fnGetProp(dpy, xwin, _atomXdndAware,
                           0, 1, 0 /* no delete */,
                           0 /* AnyPropertyType */,
                           &actualType, &actualFormat, &nItems, &bytesAfter,
                           &propData)
    defer { if let p = propData { fnFree(UnsafeMutableRawPointer(p)) } }

    return result == 0 && nItems > 0
  }

  /// Ermittelt das X11-Toplevel-Fenster unter Root-Koordinaten (rootX, rootY).
  @MainActor
  func _xdndWindowAtRoot(x rootX: Int, y rootY: Int) -> (X11WindowID, X11WindowID) {
    guard let dpy = currentDisplay,
          let fnQuery = _fnQueryPointer,
          let fnRoot  = _fnDefaultRootWindow else { return (0, 0) }
    let root = fnRoot(dpy)
    var rootRet:  X11WindowID = 0
    var childRet: X11WindowID = 0
    var rootXR: Int32 = 0, rootYR: Int32 = 0
    var winXR: Int32  = 0, winYR: Int32  = 0
    var mask: UInt32  = 0
    _ = fnQuery(dpy, root, &rootRet, &childRet,
                &rootXR, &rootYR, &winXR, &winYR, &mask)
    return (childRet, rootRet)
  }

  /// Konvertiert Root-Koordinaten in Fenster-lokale Koordinaten via XQueryPointer.
  @MainActor
  func _xdndRootToWindow(xwin: X11WindowID, rootX: Int, rootY: Int) -> (Int, Int) {
    guard let dpy = currentDisplay,
          let fnQuery = _fnQueryPointer else { return (rootX, rootY) }
    var rootRet: X11WindowID = 0
    var childRet: X11WindowID = 0
    var rootXR: Int32 = 0, rootYR: Int32 = 0
    var winXR: Int32 = 0, winYR: Int32 = 0
    var mask: UInt32 = 0
    _ = fnQuery(dpy, xwin, &rootRet, &childRet,
                &rootXR, &rootYR, &winXR, &winYR, &mask)
    // winXR/winYR = Fenster-lokale Koordinaten des Cursors
    let scale = scaleFactor
    return (Int((Double(winXR) / scale).rounded()),
            Int((Double(winYR) / scale).rounded()))
  }

  /// Gibt das AWT-Fenster und seine X11-ID zurück, das Root-Punkt (rootX, rootY) enthält.
  @MainActor
  private func _awtWindowAtRoot(rootX: Int, rootY: Int) -> (java.awt.Window, X11WindowID)? {
    let (xwin, _) = _xdndWindowAtRoot(x: rootX, y: rootY)
    guard let awtWin = _x11Registry[xwin] else { return nil }
    return (awtWin, xwin)
  }

  /// Mappt einen XDND-Aktions-Atom auf eine Java-DnD-Aktion.
  @MainActor
  func _xdndAtomToJavaAction(_ atom: UInt) -> Int {
    if atom == _atomXdndActionCopy { return _xdndJavaCopy }
    if atom == _atomXdndActionMove { return _xdndJavaMove }
    if atom == _atomXdndActionLink { return _xdndJavaLink }
    return _xdndJavaCopy  // Standard-Fallback
  }

  /// Mappt eine Java-DnD-Aktion auf den passenden XDND-Aktions-Atom.
  @MainActor
  func _xdndJavaActionToAtom(_ action: Int) -> UInt {
    if action & _xdndJavaMove != 0 { return _atomXdndActionMove }
    if action & _xdndJavaLink != 0 { return _atomXdndActionLink }
    return _atomXdndActionCopy
  }

  /// Quellaktion für ein unbekanntes Quell-Fenster (immer COPY | MOVE).
  private func state_dragAction(_ sourceWin: X11WindowID) -> Int {
    _xdndJavaCopy | _xdndJavaMove
  }

  /// HitTest — Wrapper um _SwingHitTest für Verwendung in DnD-Kontext.
  @MainActor
  private func _hitTest(x: Int, y: Int, in window: java.awt.Window) -> java.awt.Component? {
    _SwingHitTest.find(x: x, y: y, in: window)
  }

  /// Absoluten Ursprung einer Komponente in Fensterkoordinaten.
  @MainActor
  private func _absoluteOrigin(_ component: java.awt.Component) -> java.awt.Point {
    var x = 0, y = 0
    var node: java.awt.Component? = component
    while let n = node {
      x += n.bounds.x
      y += n.bounds.y
      node = n.parent
    }
    return java.awt.Point(x, y)
  }

  /// Besucht alle aktiven `DropTarget`s im Komponentenbaum.
  @MainActor
  private func _xdndVisitDropTargets(in root: java.awt.Component,
                                      block: (java.awt.dnd.DropTarget) -> Void) {
    if let dt = root.getDropTarget(), dt.isActive() { block(dt) }
    if let container = root as? java.awt.Container {
      for child in container.getComponents() {
        _xdndVisitDropTargets(in: child, block: block)
      }
    }
  }

  /// Bereinigt den Drop-Empfangszustand nach SelectionNotify.
  @MainActor
  private func _xdndClearDropState() {
    _xdndDropSourceWin = 0
    _xdndDropTargetWin = 0
    _xdndDropTimestamp = 0
    _xdndDropAwtWindow = nil
    _xdndPendingSource = 0
  }
}

// =============================================================================
// MARK: _X11XDNDInboundTransferable
// =============================================================================

/// `Transferable` für empfangene XDND-Daten (Cross-App Drop als Ziel).
final class _X11XDNDInboundTransferable: java.awt.datatransfer.Transferable,
                                          @unchecked Sendable {
  private let _text: String

  init(text: String) { _text = text }

  public func getTransferDataFlavors() -> [java.awt.datatransfer.DataFlavor] {
    [.stringFlavor]
  }

  public func isDataFlavorSupported(
      _ flavor: java.awt.datatransfer.DataFlavor) -> Bool {
    flavor == .stringFlavor
  }

  public func getTransferData(
      _ flavor: java.awt.datatransfer.DataFlavor) throws -> Any {
    guard isDataFlavorSupported(flavor) else {
      throw java.awt.datatransfer.UnsupportedFlavorException(flavor)
    }
    return _text
  }
}

#endif // os(Linux) || os(FreeBSD)
