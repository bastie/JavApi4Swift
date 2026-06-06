// SPDX-License-Identifier: Apache-2.0
//
// AWTWindowHost.swift
// JavApi⁴Swift
//
// Copyright 2025 Sebastian Ritter and contributors.
// Licensed under the Apache License, Version 2.0.
//
// AWTWindowHost ist die Brücke zwischen der plattformunabhängigen
// java.awt.Frame-API und dem nativen SwiftUI/AppKit-Fenstersystem.
//
// Architekturprinzip:
//   Frame.setVisible(true)
//       → AWTWindowHost.shared.show(frame)
//           → publiziert Frame via @Published
//               → AWTHostingWindow (SwiftUI Scene / NSWindow) reagiert
//                   → AWTCanvasView rendert Component.paint(Graphics)
//
// Plattformunterstützung:
//   macOS  — NSWindow + SwiftUI Canvas (vollständig)
//   iOS    — UIWindow + SwiftUI Canvas  (vollständig)
//   Linux  — Stub (kein nativer Fenstermanager; für headless-Tests)

import Foundation

#if canImport(SwiftUI)
import SwiftUI

// =============================================================================
// MARK: - AWTWindowHost  (Singleton — AppKit/UIKit-agnostisch)
// =============================================================================

/// Singleton-Brücke zwischen `Java.awt.Frame` und dem nativen Fenstersystem.
///
/// ### Integration in die App
///
/// **Option A — SwiftUI App (empfohlen)**
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     AWTHostingScene()          // registriert alle Frame-Fenster
///   }
/// }
/// ```
///
/// **Option B — AppDelegate-basiert (macOS)**
/// ```swift
/// AWTWindowHost.shared.install(in: NSApplication.shared)
/// ```
///
/// Danach kann portierter Java-Code unverändert laufen:
/// ```swift
/// let frame = Java.awt.Frame("Hallo Welt")
/// frame.setSize(640, 480)
/// frame.add(MyPanel())
/// frame.setVisible(true)   // öffnet ein echtes macOS/iOS-Fenster
/// ```
@MainActor
public final class AWTWindowHost: ObservableObject, Sendable {
  
  // ---------------------------------------------------------------------------
  // MARK: Singleton
  // ---------------------------------------------------------------------------
  
  public static let shared = AWTWindowHost()
  private init() {}
  
  // ---------------------------------------------------------------------------
  // MARK: State
  // ---------------------------------------------------------------------------
  
  /// Alle aktuell sichtbaren Fenster, in Anzeigereihenfolge.
  @Published public private(set) var visibleFrames: [java.awt.Window] = []

  /// Interner Zugriff ohne Lock — nur auf Main-Thread aufrufen.
  private var frameRegistry: [ObjectIdentifier: java.awt.Window] = [:]

  // ---------------------------------------------------------------------------
  // MARK: Fenster-Lebenszyklusverwaltung
  // ---------------------------------------------------------------------------

  /// Macht `window` sichtbar. Wird von `Window.setVisible(true)` aufgerufen.
  public func show(_ window: java.awt.Window) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(window)
      guard self.frameRegistry[id] == nil else { return }   // Duplikatschutz
      self.frameRegistry[id] = window
      self.visibleFrames.append(window)
    }
  }

  /// Versteckt `window`. Wird von `Window.setVisible(false)` / `dispose()` aufgerufen.
  public func hide(_ window: java.awt.Window) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let id = ObjectIdentifier(window)
      self.frameRegistry.removeValue(forKey: id)
      self.visibleFrames.removeAll { ObjectIdentifier($0) == id }
    }
  }
}

// =============================================================================
// MARK: - AWTCanvasView  (rendert einen java.awt.Component via SwiftUI Canvas)
// =============================================================================

/// SwiftUI-View, das einen `Java.awt.Component` durch Aufruf von
/// `paint(Graphics)` zeichnet.
///
/// Die SwiftUI `Canvas` stellt einen `CGContext` bereit; daraus wird eine
/// `Java.awt.Graphics2D`-Instanz gebaut und an `component.paint` übergeben.
struct AWTCanvasView: View {
  
  /// Die zu rendernde AWT-Komponente.
  let component: java.awt.Component
  
  var body: some View {
    _AWTCanvasViewRepresentable(component: component)
      .frame(
        width:  CGFloat(component.bounds.width),
        height: CGFloat(component.bounds.height))
  }
}

// ---------------------------------------------------------------------------
// MARK: ViewRepresentable-Brücke (macOS / iOS)
// ---------------------------------------------------------------------------

#if os(macOS)
import AppKit

private struct _AWTCanvasViewRepresentable: NSViewRepresentable {
  
  let component: java.awt.Component
  
  func makeNSView(context: Context) -> _AWTNativeCanvas {
    let v = _AWTNativeCanvas()
    v.component = component
    return v
  }
  
  func updateNSView(_ nsView: _AWTNativeCanvas, context: Context) {
    nsView.component = component
    nsView.needsDisplay = true
  }
}

/// Natives NSView, das `component.paint(g)` in `draw(_:)` aufruft
/// und Mausereignisse als AWT-Events weiterleitet.
@MainActor
final class _AWTNativeCanvas: NSView {

  var component: java.awt.Component?

  override var acceptsFirstResponder: Bool { true }

  override func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    // Wenn das NSWindow seine Größe ändert, passen wir frame.bounds an
    // und rufen validate() auf, damit alle LayoutManager neu rechnen.
    if let frame = component as? java.awt.Frame {
      let newW = Int(newSize.width)
      let newH = Int(newSize.height)
      guard frame.bounds.width != newW || frame.bounds.height != newH else { return }
      frame.bounds = java.awt.Rectangle(0, 0, newW, newH)
      frame.validate()
    }
    needsDisplay = true
  }

  override func draw(_ dirtyRect: NSRect) {
    guard let component,
          let cgContext = NSGraphicsContext.current?.cgContext else { return }
    cgContext.saveGState()
    cgContext.translateBy(x: 0, y: bounds.height)
    cgContext.scaleBy(x: 1, y: -1)
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
    cgContext.restoreGState()
  }

  // NSView Y: bottom-left origin → AWT Y: top-left origin
  private func awtPoint(from event: NSEvent) -> CGPoint {
    let p = convert(event.locationInWindow, from: nil)
    return CGPoint(x: p.x, y: bounds.height - p.y)
  }

  private var pressedButton: java.awt.Button?

  // Scrollbar being dragged (for thumb drag)
  private var draggingScrollbar: java.awt.Scrollbar?
  // TextArea whose scrollbar thumb is being dragged
  private var draggingTextAreaScroll: java.awt.TextArea?
  // ScrollPane whose scrollbar thumb is being dragged
  private var draggingScrollPane: java.awt.ScrollPane?
  // List whose scrollbar is being dragged
  private var draggingList: java.awt.List?
  // Currently open Choice popup (tracked so outside clicks close it)
  private weak var openChoice: java.awt.Choice?

  override func mouseDown(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)

    // ── Choice popup handling (must come before normal hit-test) ────────────
    if let choice = openChoice {
      let pr = choice.popupRect()
      if pr.contains(Int(pt.x), Int(pt.y)) {
        // Click inside popup → select item and close
        if let idx = choice.popupItemIndex(atY: Int(pt.y)) {
          choice.select(idx)
          choice.fireItemEvent(index: idx)
        }
        choice.isOpen = false
        openChoice    = nil
        needsDisplay  = true
        return
      } else {
        // Click outside popup → just close it
        choice.isOpen = false
        openChoice    = nil
        needsDisplay  = true
        // Fall through to normal dispatch for the actual click target
      }
    }

    let hit = AWTHitTest.find(at: pt, in: component)

    // Transfer keyboard focus
    AWTFocusManager.shared.requestFocus(hit)

    if let btn = hit as? java.awt.Button {
      pressedButton = btn
      btn.isPressed = true
      needsDisplay  = true

    } else if let tf = hit as? java.awt.TextField {
      let clickIdx = tf.charIndex(at: Int(pt.x))
      if event.modifierFlags.contains(.shift) {
        tf.extendSelection(to: clickIdx)
      } else {
        tf.setCaretPosition(clickIdx)
      }
      needsDisplay = true

    } else if let ta = hit as? java.awt.TextArea {
      // Check if click hit the internal vertical scrollbar thumb
      if let thumb = ta.verticalScrollbarThumbRect(),
         thumb.contains(Int(pt.x), Int(pt.y)) {
        draggingTextAreaScroll = ta
        ta.isScrollbarDragging = true
        ta.scrollDragStartY    = Int(pt.y)
        ta.scrollDragStartOff  = ta.scrollOffsetY
      } else {
        // Position caret in text area
        let idx = ta.charIndex(atX: Int(pt.x), atY: Int(pt.y))
        if event.modifierFlags.contains(.shift) {
          ta.extendSelection(to: idx)
        } else {
          ta.setCaretPosition(idx)
        }
      }
      needsDisplay = true

    } else if let sb = hit as? java.awt.Scrollbar {
      // Begin scrollbar thumb drag
      let thumb = sb.thumbRect()
      let coord = sb.orientation == java.awt.Scrollbar.VERTICAL ? Int(pt.y) : Int(pt.x)
      if thumb.contains(Int(pt.x), Int(pt.y)) {
        draggingScrollbar        = sb
        sb.isDragging            = true
        sb.dragStartCoord        = coord
        sb.dragStartValue        = sb.value
      }
      needsDisplay = true

    } else if let sp = hit as? java.awt.ScrollPane {
      // Hit the ScrollPane itself → must be a scrollbar strip
      let ptI = (x: Int(pt.x), y: Int(pt.y))
      if let thumb = sp.vThumbRect(), thumb.contains(ptI.x, ptI.y) {
        draggingScrollPane      = sp
        sp.isDraggingV          = true
        sp.dragStartY           = ptI.y
        sp.dragStartScrollY     = sp.scrollY
      } else if let thumb = sp.hThumbRect(), thumb.contains(ptI.x, ptI.y) {
        draggingScrollPane      = sp
        sp.isDraggingH          = true
        sp.dragStartX           = ptI.x
        sp.dragStartScrollX     = sp.scrollX
      }
      needsDisplay = true

    } else if let ch = hit as? java.awt.Choice {
      // Toggle popup
      ch.isOpen   = !ch.isOpen
      openChoice  = ch.isOpen ? ch : nil
      needsDisplay = true

    } else if let list = hit as? java.awt.List {
      let ptI = (x: Int(pt.x), y: Int(pt.y))
      if let thumb = list.scrollbarThumbRect(), thumb.contains(ptI.x, ptI.y) {
        // Begin scrollbar thumb drag
        draggingList                = list
        list.isScrollbarDragging   = true
        list.scrollDragStartY      = ptI.y
        list.scrollDragStartOff    = list.scrollOffset
      } else {
        // Item selection
        if let idx = list.itemIndex(atY: ptI.y) {
          list.select(idx)
          list.fireItemEvent(index: idx,
                             stateChange: java.awt.event.ItemEvent.SELECTED)
          if event.clickCount >= 2 {
            list.fireActionEvent(index: idx)
          }
        }
      }
      needsDisplay = true
    }
  }

  override func mouseDragged(with event: NSEvent) {
    let pt = awtPoint(from: event)

    // ScrollPane scrollbar drag
    if let sp = draggingScrollPane {
      if sp.isDraggingV, let track = sp.vScrollbarRect() {
        let (_, maxY) = sp.maxScroll()
        guard maxY > 0 else { return }
        let dy = Int(pt.y) - sp.dragStartY
        let newY = sp.dragStartScrollY + dy * maxY / max(1, track.height)
        sp.setScrollPosition(sp.scrollX, newY)
      } else if sp.isDraggingH, let track = sp.hScrollbarRect() {
        let (maxX, _) = sp.maxScroll()
        guard maxX > 0 else { return }
        let dx = Int(pt.x) - sp.dragStartX
        let newX = sp.dragStartScrollX + dx * maxX / max(1, track.width)
        sp.setScrollPosition(newX, sp.scrollY)
      }
      needsDisplay = true
      return
    }

    // TextArea internal scrollbar
    if let ta = draggingTextAreaScroll {
      let fm      = ta.getFontMetrics(ta.font)
      let lineH   = max(1, fm.getHeight())
      let lines   = ta.computeLines()
      let totalH  = lines.count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      guard totalH > visibleH else { return }
      let trackH   = ta.bounds.height
      let dy       = Int(pt.y) - ta.scrollDragStartY
      let newOff   = ta.scrollDragStartOff + dy * totalH / max(1, trackH)
      ta.scrollOffsetY = max(0, min(totalH - visibleH, newOff))
      needsDisplay = true
      return
    }

    // Standalone Scrollbar thumb drag
    if let sb = draggingScrollbar {
      let range  = sb.maximum - sb.minimum
      let isVert = sb.orientation == java.awt.Scrollbar.VERTICAL
      let track  = isVert ? sb.bounds.height : sb.bounds.width
      let coord  = isVert ? Int(pt.y) : Int(pt.x)
      let delta  = coord - sb.dragStartCoord
      let newVal = sb.dragStartValue + delta * range / max(1, track)
      let old    = sb.value
      sb.value   = newVal
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: true)
      }
      needsDisplay = true
      return
    }

    // TextField selection drag
    if let tf = AWTFocusManager.shared.focusOwner as? java.awt.TextField {
      let idx = tf.charIndex(at: Int(pt.x))
      tf.extendSelection(to: idx)
      needsDisplay = true
      return
    }

    // TextArea selection drag
    if let ta = AWTFocusManager.shared.focusOwner as? java.awt.TextArea {
      let idx = ta.charIndex(atX: Int(pt.x), atY: Int(pt.y))
      ta.extendSelection(to: idx)
      needsDisplay = true
      return
    }

    // List scrollbar drag
    if let list = draggingList {
      guard list.needsScrollbar() else { return }
      let trackH  = list.bounds.height
      let maxOff  = list.maxScrollOffset()
      let dy      = Int(pt.y) - list.scrollDragStartY
      let newOff  = list.scrollDragStartOff + dy * maxOff / max(1, trackH)
      list.scrollOffset = max(0, min(maxOff, newOff))
      needsDisplay = true
    }
  }

  override func mouseUp(with event: NSEvent) {
    // End ScrollPane drag
    if let sp = draggingScrollPane {
      sp.isDraggingV    = false
      sp.isDraggingH    = false
      draggingScrollPane = nil
      needsDisplay = true
      return
    }

    // End scrollbar drags
    if let ta = draggingTextAreaScroll {
      ta.isScrollbarDragging = false
      draggingTextAreaScroll = nil
      needsDisplay = true
      return
    }
    if let sb = draggingScrollbar {
      sb.isDragging     = false
      draggingScrollbar = nil
      sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.TRACK, isAdjusting: false)
      needsDisplay = true
      return
    }

    // End List scrollbar drag
    if let list = draggingList {
      list.isScrollbarDragging = false
      draggingList = nil
      needsDisplay = true
      return
    }

    // Release button press
    if let btn = pressedButton {
      btn.isPressed  = false
      pressedButton  = nil
      let pt = awtPoint(from: event)
      if let hit = AWTHitTest.find(at: pt, in: component ?? btn),
         hit === btn {
        btn.doClick()
      }
      needsDisplay = true
      return
    }

    // Other components — TextComponent handled in mouseDown/mouseDragged
    guard let component else { return }
    let pt = awtPoint(from: event)
    if let hit = AWTHitTest.find(at: pt, in: component),
       !(hit is java.awt.TextComponent) {
      AWTHitTest.dispatch(click: hit)
      needsDisplay = true
    }
  }

  override func scrollWheel(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    guard let hit = AWTHitTest.find(at: pt, in: component) else { return }

    if let sp = hit as? java.awt.ScrollPane {
      let dy = Int(event.scrollingDeltaY * -3)
      let dx = Int(event.scrollingDeltaX * -3)
      sp.setScrollPosition(sp.scrollX + dx, sp.scrollY + dy)
      needsDisplay = true
    } else if let ta = hit as? java.awt.TextArea {
      let delta = Int(event.scrollingDeltaY * -3)
      let fm      = ta.getFontMetrics(ta.font)
      let lineH   = max(1, fm.getHeight())
      let lines   = ta.computeLines()
      let totalH  = lines.count * lineH
      let visibleH = ta.bounds.height - 2 * ta.padY
      let maxOff  = max(0, totalH - visibleH)
      ta.scrollOffsetY = max(0, min(maxOff, ta.scrollOffsetY + delta))
      needsDisplay = true
    } else if let sb = hit as? java.awt.Scrollbar {
      let delta = Int(event.scrollingDeltaY)
      let old   = sb.value
      sb.value  = sb.value + (sb.orientation == java.awt.Scrollbar.VERTICAL ? delta : -delta)
      if sb.value != old {
        sb.fireAdjustment(type: java.awt.event.AdjustmentEvent.UNIT_INCREMENT)
      }
      needsDisplay = true
    } else if let list = hit as? java.awt.List {
      let delta = Int(event.scrollingDeltaY)
      let maxOff = list.maxScrollOffset()
      list.scrollOffset = max(0, min(maxOff, list.scrollOffset + delta))
      needsDisplay = true
    }
  }

  override func rightMouseDown(with event: NSEvent) {
    guard let component else { return }
    let pt  = awtPoint(from: event)
    guard let hit = AWTHitTest.find(at: pt, in: component) else { return }
    guard let popup = hit.popupMenu else { return }
    popup.showAtEvent(event, in: self)
  }

  override func keyDown(with event: NSEvent) {
    let fm   = AWTFocusManager.shared
    let mods = event.modifierFlags
    let hasCmd   = mods.contains(.command)
    let hasShift = mods.contains(.shift)

    switch event.keyCode {

    // Backspace
    case 51:
      fm.handleBackspace()
      needsDisplay = true

    // Forward Delete
    case 117:
      fm.handleDelete()
      needsDisplay = true

    // Return / Enter
    case 36, 76:
      fm.handleEnter()
      needsDisplay = true

    // Left arrow
    case 123:
      if hasCmd {
        fm.moveCaretToEnd(end: false, extending: hasShift)  // Cmd+Left → line start
      } else {
        fm.moveCaret(by: -1, extending: hasShift)
      }
      needsDisplay = true

    // Right arrow
    case 124:
      if hasCmd {
        fm.moveCaretToEnd(end: true, extending: hasShift)   // Cmd+Right → line end
      } else {
        fm.moveCaret(by: 1, extending: hasShift)
      }
      needsDisplay = true

    // Up arrow
    case 126:
      fm.moveCaretUp(extending: hasShift)
      needsDisplay = true

    // Down arrow
    case 125:
      fm.moveCaretDown(extending: hasShift)
      needsDisplay = true

    default:
      if hasCmd {
        switch event.keyCode {
        case 0:  // Cmd+A — Select All
          fm.selectAll()
          needsDisplay = true
        case 8:  // Cmd+C — Copy
          fm.copySelection()
        case 9:  // Cmd+V — Paste
          fm.pasteText()
          needsDisplay = true
        case 7:  // Cmd+X — Cut
          fm.cutSelection()
          needsDisplay = true
        default:
          super.keyDown(with: event)
        }
      } else if let chars = event.characters, !chars.isEmpty {
        var typed = false
        for ch in chars {
          let v = ch.unicodeScalars.first?.value ?? 0
          if v >= 32 && v != 127 {
            fm.typeCharacter(ch)
            typed = true
          }
        }
        if typed { needsDisplay = true }
        else     { super.keyDown(with: event) }
      } else {
        super.keyDown(with: event)
      }
    }
  }
}

#elseif os(iOS) || os(tvOS)
import UIKit

private struct _AWTCanvasViewRepresentable: UIViewRepresentable {
  
  let component: java.awt.Component
  
  func makeUIView(context: Context) -> _AWTNativeCanvas {
    let v = _AWTNativeCanvas()
    v.component = component
    return v
  }
  
  func updateUIView(_ uiView: _AWTNativeCanvas, context: Context) {
    uiView.component = component
    uiView.setNeedsDisplay()
  }
}

/// Natives UIView, das `component.paint(g)` in `draw(_:)` aufruft
/// und Touch-Events als AWT-Events weiterleitet.
@MainActor
final class _AWTNativeCanvas: UIView {

  var component: java.awt.Component?

  override func draw(_ rect: CGRect) {
    guard let component,
          let cgContext = UIGraphicsGetCurrentContext() else { return }
    let g = java.awt.Graphics2D(cgContext)
    component.paint(g)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let component, let touch = touches.first else { return }
    let p = touch.location(in: self)
    // UIKit: Y already goes down — same as AWT, no conversion needed
    if let hit = AWTHitTest.find(at: p, in: component) {
      AWTHitTest.dispatch(click: hit)
      setNeedsDisplay()
    }
  }
}

#else
// ---------------------------------------------------------------------------
// MARK: Linux / headless stub
// ---------------------------------------------------------------------------

private struct _AWTCanvasViewRepresentable: View {
  let component: java.awt.Component
  var body: some View { EmptyView() }
}

#endif   // os(macOS) / os(iOS) / else


// =============================================================================
// MARK: - AWTFrameWindow  (ein Fenster pro java.awt.Window)
// =============================================================================

/// SwiftUI-View, das ein `java.awt.Window` als vollständiges Fenster darstellt
/// — Titelzeile (falls `Frame`) + Inhalt.
public struct AWTFrameWindow: View {

  @ObservedObject var host = AWTWindowHost.shared
  public let window: java.awt.Window

  /// Rückwärtskompatibel: nimmt weiterhin einen Frame an.
  public init(frame: java.awt.Frame) {
    self.window = frame
  }

  public init(window: java.awt.Window) {
    self.window = window
  }

  public var body: some View {
    VStack(spacing: 0) {

      // Titelzeile (auf Plattformen ohne native Fensterchrome)
      HStack {
        Text((window as? java.awt.Frame)?.title ?? "")
          .font(.headline)
          .padding(.horizontal, 8)
        Spacer()
        Button("✕") { AWTWindowHost.shared.hide(window) }
          .padding(.trailing, 8)
      }
      .frame(height: 28)
      .background(Color(white: 0.85))

      // Zeichenfläche
      AWTCanvasView(component: window)
    }
    .frame(
      width:  CGFloat(window.bounds.width),
      height: CGFloat(window.bounds.height + 28))
    .background(
      Color(
        red:   window.background.red,
        green: window.background.green,
        blue:  window.background.blue))
  }
}

// =============================================================================
// MARK: - AWTHostingScene  (SwiftUI App-Integration)
// =============================================================================

/// Eine SwiftUI `Scene`, die automatisch für jeden sichtbaren `Java.awt.Frame`
/// ein Fenster öffnet.
///
/// Einbindung in die App:
/// ```swift
/// @main struct MyApp: App {
///   var body: some Scene {
///     AWTHostingScene()
///   }
/// }
/// ```
public struct AWTHostingScene: Scene {
  
  @StateObject private var host = AWTWindowHost.shared
  
  public init() {}
  
  public var body: some Scene {
#if os(macOS)
    // Auf macOS öffnet jedes Frame als eigenes Fenster.
    WindowGroup("AWT") {
      AWTMultiWindowView()
        .environmentObject(host)
    }
#else
    // Auf iOS zeigen wir alle Frames gestapelt in einem einzigen Window.
    WindowGroup {
      AWTMultiWindowView()
        .environmentObject(host)
    }
#endif
  }
}

// ---------------------------------------------------------------------------
// MARK: AWTMultiWindowView  (zeigt alle sichtbaren Frames)
// ---------------------------------------------------------------------------

/// Root-View, die alle aktuell sichtbaren `java.awt.Window`-Instanzen rendert.
///
/// Auf macOS erscheint jedes Window als überlappbares Panel innerhalb des
/// SwiftUI-Fensters. Für echte separate NSWindow-Instanzen kann
/// `AWTWindowHost` mit AppKit erweitert werden (siehe `openNewWindow`).
public struct AWTMultiWindowView: View {

  @EnvironmentObject var host: AWTWindowHost

  public init() {}

  public var body: some View {
    ZStack(alignment: .topLeading) {
      if host.visibleFrames.isEmpty {
        Text("Kein AWT-Fenster sichtbar")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ForEach(host.visibleFrames, id: \.objectID) { window in
          AWTFrameWindow(window: window)
            .offset(
              x: CGFloat(window.bounds.x),
              y: CGFloat(window.bounds.y))
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.95))
  }
}

// =============================================================================
// MARK: - macOS: Echte separate NSWindow-Instanzen (optional)
// =============================================================================

#if os(macOS)
import AppKit

// ---------------------------------------------------------------------------
// MARK: NSWindowDelegate — erzwingt Mindest- und Höchstgröße aus AWT
// ---------------------------------------------------------------------------

private final class AWTWindowSizeDelegate: NSObject, NSWindowDelegate {

  private weak var awtWindow: java.awt.Window?

  init(_ awtWindow: java.awt.Window) {
    self.awtWindow = awtWindow
  }

  func windowWillClose(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    // WINDOW_CLOSING wird bereits in Window.setVisible(false) gefeuert,
    // aber nur wenn der Schließvorgang von AWT initiiert wurde.
    // Hier fangen wir den nativen X-Button ab.
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_CLOSING))
    }
  }

  func windowDidBecomeKey(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_ACTIVATED))
    }
  }

  func windowDidResignKey(_ notification: Notification) {
    guard let awt = awtWindow else { return }
    Task { @MainActor in
      awt.processWindowEvent(
        java.awt.event.WindowEvent(awt, java.awt.event.WindowEvent.WINDOW_DEACTIVATED))
    }
  }

  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    guard let awt = awtWindow else { return frameSize }

    let minAWT = awt.getMinimumSize()
    let maxAWT = awt.getMaximumSize()

    // Titelleistenhöhe = Gesamtfenster − Inhaltsbereich
    let titleBarH = sender.frame.height
                  - sender.contentRect(forFrameRect: sender.frame).height

    var w = frameSize.width
    var h = frameSize.height

    // Minimum
    if minAWT.width  > 0 { w = max(w, CGFloat(minAWT.width))  }
    if minAWT.height > 0 { h = max(h, CGFloat(minAWT.height) + titleBarH) }

    // Maximum (Int.max bedeutet unbegrenzt)
    if maxAWT.width  < Int.max { w = min(w, CGFloat(maxAWT.width))  }
    if maxAWT.height < Int.max { h = min(h, CGFloat(maxAWT.height) + titleBarH) }

    return NSSize(width: w, height: h)
  }
}

extension AWTWindowHost {
  
  /// Öffnet ein `java.awt.Window` als eigenständiges `NSWindow`.
  ///
  /// Rufe dies statt `show(_:)` auf, wenn du echte separate Fenster
  /// mit nativem macOS-Chrome möchtest:
  /// ```swift
  /// AWTWindowHost.shared.openNewWindow(for: myFrame)
  /// ```
  @MainActor
  public func openNewWindow(for awtWindow: java.awt.Window) {
    // Komponentenbaum vollständig layouten
    awtWindow.validate()

    // Kein festes .frame() → NSHostingView füllt das NSWindow aus;
    // setFrameSize in _AWTNativeCanvas löst validate() aus, wenn sich die Größe ändert.
    let hostingView = NSHostingView(
      rootView: _AWTCanvasViewRepresentable(component: awtWindow)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea())
    hostingView.autoresizingMask = [.width, .height]

    let nsWindow = NSWindow(
      contentRect: NSRect(
        x: awtWindow.bounds.x, y: awtWindow.bounds.y,
        width: awtWindow.bounds.width, height: awtWindow.bounds.height),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false)

    nsWindow.title = (awtWindow as? java.awt.Frame)?.title ?? ""
    nsWindow.contentView = hostingView
    nsWindow.isReleasedWhenClosed = false

    // Delegate erzwingt Mindest-/Höchstgröße zuverlässig über windowWillResize.
    // Der Delegate muss stark gehalten werden — wir hängen ihn ans NSWindow.
    let sizeDelegate = AWTWindowSizeDelegate(awtWindow)
    nsWindow.delegate = sizeDelegate
    // NSWindow hält delegate nur weak → wir speichern ihn als assoziiertes Objekt.
    objc_setAssociatedObject(nsWindow, &AWTWindowHost.delegateKey,
                             sizeDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    if awtWindow.bounds.x == 0 && awtWindow.bounds.y == 0 {
      nsWindow.center()
    }
    nsWindow.makeKeyAndOrderFront(nil)

    // Schließen-Button → Window.setVisible(false) / dispose()
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: nsWindow,
      queue: .main) { [weak self] _ in
        guard let self else { return }
        Task { @MainActor in
          self.hide(awtWindow)
        }
      }
  }

  /// Schlüssel für `objc_setAssociatedObject` — hält den Delegate am Leben.
  private static var delegateKey: UInt8 = 0

  // ---------------------------------------------------------------------------
  // MARK: MenuBar
  // ---------------------------------------------------------------------------

  /// Bindet eine `java.awt.MenuBar` an das native NSWindow des gegebenen Frames.
  ///
  /// Die Menüleiste wird als `NSMenu` aufgebaut und in `NSApp.mainMenu` eingehängt,
  /// sobald das Fenster key wird. Wird `nil` übergeben, wird die Menüleiste entfernt.
  @MainActor
  public func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
    guard let menuBar else {
      // Menüleiste entfernen — macOS-Standard-Menü bleibt
      return
    }
    let nsMenu = buildNSMenu(from: menuBar)
    NSApp.mainMenu = nsMenu
  }

  /// Wandelt eine `java.awt.MenuBar` in eine `NSMenu`-Hierarchie um.
  @MainActor
  private func buildNSMenu(from menuBar: java.awt.MenuBar) -> NSMenu {
    let mainMenu = NSMenu(title: "MainMenu")
    for menu in menuBar.getMenus() {
      let topItem = NSMenuItem(title: menu.getLabel(), action: nil, keyEquivalent: "")
      let submenu = buildNSSubmenu(from: menu)
      topItem.submenu = submenu
      mainMenu.addItem(topItem)
    }
    return mainMenu
  }

  /// Wandelt ein `java.awt.Menu` in ein `NSMenu` um (rekursiv für Untermenüs).
  @MainActor
  private func buildNSSubmenu(from menu: java.awt.Menu) -> NSMenu {
    let nsMenu = NSMenu(title: menu.getLabel())
    for item in menu.getItems() {
      nsMenu.addItem(makeNSMenuItem(from: item))
    }
    return nsMenu
  }

  /// Erzeugt ein einzelnes `NSMenuItem` aus einem `java.awt.MenuItem`.
  @MainActor
  func makeNSMenuItem(from item: java.awt.MenuItem) -> NSMenuItem {
    // Trennstrich
    if item.getLabel() == "-" {
      return NSMenuItem.separator()
    }

    let nsItem: NSMenuItem

    if let cbItem = item as? java.awt.CheckboxMenuItem {
      // CheckboxMenuItem
      let handler = AWTMenuItemTarget(menuItem: cbItem as java.awt.MenuItem)
      nsItem = NSMenuItem(title: cbItem.getLabel(),
                          action: #selector(AWTMenuItemTarget.trigger),
                          keyEquivalent: keyEquivalent(for: cbItem))
      nsItem.target = handler
      nsItem.state  = cbItem.getState() ? .on : .off
      objc_setAssociatedObject(nsItem, &AWTWindowHost.menuTargetKey,
                               handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    } else if let subMenu = item as? java.awt.Menu {
      // Untermenü
      nsItem = NSMenuItem(title: subMenu.getLabel(), action: nil, keyEquivalent: "")
      nsItem.submenu = buildNSSubmenu(from: subMenu)
    } else {
      // Normaler MenuItem
      let handler = AWTMenuItemTarget(menuItem: item)
      nsItem = NSMenuItem(title: item.getLabel(),
                          action: #selector(AWTMenuItemTarget.trigger),
                          keyEquivalent: keyEquivalent(for: item))
      nsItem.target = handler
      if let sc = item.shortcut {
        nsItem.keyEquivalentModifierMask = sc.usesShiftModifier() ? [.command, .shift] : [.command]
      }
      objc_setAssociatedObject(nsItem, &AWTWindowHost.menuTargetKey,
                               handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    nsItem.isEnabled = item.isEnabled()
    return nsItem
  }

  private static var menuTargetKey: UInt8 = 1

  /// Gibt das `keyEquivalent`-String für ein `MenuItem` zurück.
  private func keyEquivalent(for item: java.awt.MenuItem) -> String {
    guard let sc = item.shortcut else { return "" }
    // sc.key ist ein java.awt.event.KeyEvent-Konstant (ASCII-Wert für Buchstaben)
    let ch = sc.key
    if ch >= 65 && ch <= 90 {
      return String(UnicodeScalar(ch + 32)!)  // uppercase → lowercase
    } else if ch >= 97 && ch <= 122 {
      return String(UnicodeScalar(ch)!)
    }
    return ""
  }

  /// Rückwärtskompatible Überladung für bestehenden Code.
  @MainActor
  public func openNewWindow(for frame: java.awt.Frame) {
    openNewWindow(for: frame as java.awt.Window)
  }

  // ---------------------------------------------------------------------------
  // MARK: Dialog
  // ---------------------------------------------------------------------------

  /// Öffnet einen `java.awt.Dialog` als natives NSPanel.
  ///
  /// - Modaler Dialog (`modal == true`): wird als Sheet am Besitzerfenster
  ///   angehängt wenn ein Besitzer vorhanden ist, sonst als `runModal`-Block.
  /// - Nicht-modaler Dialog: verhält sich wie ein normales Fenster.
  @MainActor
  public func openDialog(_ dialog: java.awt.Dialog) {
    dialog.validate()

    let hostingView = NSHostingView(
      rootView: _AWTCanvasViewRepresentable(component: dialog)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea())
    hostingView.autoresizingMask = [.width, .height]

    var styleMask: NSWindow.StyleMask = [.titled, .closable]
    if dialog.resizable { styleMask.insert(.resizable) }

    let nsPanel = NSPanel(
      contentRect: NSRect(
        x: dialog.bounds.x, y: dialog.bounds.y,
        width:  max(dialog.bounds.width,  200),
        height: max(dialog.bounds.height, 100)),
      styleMask: styleMask,
      backing: .buffered,
      defer: false)

    nsPanel.title              = dialog.getTitle()
    nsPanel.contentView        = hostingView
    nsPanel.isReleasedWhenClosed = false
    nsPanel.becomesKeyOnlyIfNeeded = !dialog.isModal()

    // Größenconstraints
    let sizeDelegate = AWTWindowSizeDelegate(dialog)
    nsPanel.delegate = sizeDelegate
    objc_setAssociatedObject(nsPanel, &AWTWindowHost.delegateKey,
                             sizeDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    // nsPanel am Dialog-Objekt hängen — damit closeDialog(_:) es findet
    objc_setAssociatedObject(dialog, &AWTWindowHost.dialogPanelKey,
                             nsPanel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    // Schließen über nativen X-Button → AWT-Zustand aufräumen
    NotificationCenter.default.addObserver(
      forName: NSWindow.willCloseNotification,
      object: nsPanel,
      queue: .main) { [weak self] _ in
        guard let self else { return }
        Task { @MainActor in self.hide(dialog) }
      }

    if dialog.isModal() {
      // Besitzerfenster als Sheet, falls vorhanden
      let ownerNS = NSApp.windows.first { $0.title == (dialog.owner as? java.awt.Frame)?.title
                                       || $0.title == (dialog.owner as? java.awt.Dialog)?.getTitle() }
      if let ownerNS {
        ownerNS.beginSheet(nsPanel) { _ in }
        // Sheet-Panel ebenfalls am Dialog merken (gleicher Key)
      } else {
        // Kein Besitzer → modaler Loop
        if dialog.bounds.x == 0 && dialog.bounds.y == 0 { nsPanel.center() }
        nsPanel.makeKeyAndOrderFront(nil)
        NSApp.runModal(for: nsPanel)
      }
    } else {
      if dialog.bounds.x == 0 && dialog.bounds.y == 0 { nsPanel.center() }
      nsPanel.makeKeyAndOrderFront(nil)
    }
  }

  /// Schließt einen Dialog programmatisch (z.B. vom Schließen-Button).
  /// Beendet `runModal`-Loop oder Sheet und schließt das NSPanel.
  @MainActor
  public func closeDialog(_ dialog: java.awt.Dialog) {
    guard let nsPanel = objc_getAssociatedObject(dialog, &AWTWindowHost.dialogPanelKey)
            as? NSPanel else {
      // Fallback: einfach hide
      hide(dialog)
      return
    }

    if dialog.isModal() {
      if let parent = nsPanel.sheetParent {
        parent.endSheet(nsPanel)
      } else {
        NSApp.stopModal()
      }
    }
    nsPanel.orderOut(nil)
    hide(dialog)
  }

  private static var dialogPanelKey: UInt8 = 2
}

// ---------------------------------------------------------------------------
// MARK: AWTMenuItemTarget — Objective-C-Ziel für NSMenuItem-Aktionen
// ---------------------------------------------------------------------------

/// Hält einen starken Verweis auf ein `java.awt.MenuItem` und leitet
/// NSMenuItem-Aktionen an dessen `doAction()` weiter.
@MainActor
@objc private final class AWTMenuItemTarget: NSObject {
  private let menuItem: java.awt.MenuItem
  init(menuItem: java.awt.MenuItem) { self.menuItem = menuItem }

  @objc func trigger(_ sender: Any?) {
    menuItem.doAction()
  }
}

#endif   // os(macOS)

#endif   // canImport(SwiftUI)

