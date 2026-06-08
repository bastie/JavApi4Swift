/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi
import Foundation
#if canImport(AppKit)
import AppKit
#endif

// ---------------------------------------------------------------------------
// MARK: - Custom Canvas components
// ---------------------------------------------------------------------------

/// Draws sample polygons — demonstrates drawPolygon/fillPolygon.
@MainActor
final class PolygonCanvas: java.awt.Canvas {
  override func paint(_ g: java.awt.Graphics) {
    let w = bounds.width, h = bounds.height
    guard w > 4, h > 4 else { return }

    // Hintergrund
    g.setColor(.darkGray)
    g.fillRect(bounds.x, bounds.y, w, h)

    let ox = bounds.x, oy = bounds.y

    // Gefülltes Dreieck (blau)
    g.setColor(.blue)
    let tri = java.awt.Polygon(
      xpoints: [ox + w/2,  ox + w - 4, ox + 4],
      ypoints: [oy + 4,    oy + h/2,   oy + h/2],
      npoints: 3)
    g.fillPolygon(tri)

    // Umriss-Stern (gelb) — 6-Punkt-Stern über zwei Dreiecke
    g.setColor(.yellow)
    let cx = ox + w/2, cy = oy + h*3/4
    let r1 = Swift.min(w, h) / 5
    let r2 = r1 / 2
    var sx = [Int](), sy = [Int]()
    for i in 0..<6 {
      let angle1 = Double(i) * Double.pi / 3.0 - Double.pi / 2
      let angle2 = angle1 + Double.pi / 6.0
      sx.append(cx + Int(Double(r1) * cos(angle1)))
      sy.append(cy + Int(Double(r1) * sin(angle1)))
      sx.append(cx + Int(Double(r2) * cos(angle2)))
      sy.append(cy + Int(Double(r2) * sin(angle2)))
    }
    g.drawPolygon(sx, sy, 12)

    // Label
    g.setColor(.white)
    g.drawString("Polygon", ox + 2, oy + h - 4)
  }
}

// ---------------------------------------------------------------------------
// MARK: - GridLayout demo panel (standalone function, reused in buildShowcase)
// ---------------------------------------------------------------------------

/// Baut ein 3×2-GridLayout-Panel mit farbigen Label-Zellen.
@MainActor
func makeGridPanel(width: Int, height: Int) -> java.awt.Panel {
  let panel = java.awt.Panel(java.awt.GridLayout(2, 3, 2, 2))
  panel.setPreferredSize(java.awt.Dimension(width, height))
  let colours: [(java.awt.Color, String)] = [
    (.red,     "Rot"),    (.green,   "Grün"),  (.blue,   "Blau"),
    (.yellow,  "Gelb"),   (.cyan,    "Cyan"),  (.magenta,"Magenta")
  ]
  for (col, name) in colours {
    let lbl = java.awt.Label(name, java.awt.Label.CENTER)
    lbl.background = col
    lbl.foreground = .white
    panel.add(lbl)
  }
  return panel
}

// ---------------------------------------------------------------------------
// MARK: - CardLayout demo panel
// ---------------------------------------------------------------------------

/// Panel mit CardLayout — drei Karten, umschaltbar per Buttons.
@MainActor
final class CardDemoPanel: java.awt.Panel {

  private let cards   = java.awt.CardLayout()
  private let cardBox: java.awt.Panel

  override init() {
    cardBox = java.awt.Panel(cards)
    super.init()
    setLayout(java.awt.BorderLayout())

    // Drei Karten
    let card1 = java.awt.Label("Karte 1 — Start", java.awt.Label.CENTER)
    card1.background = .blue
    card1.foreground = .white
    let card2 = java.awt.Label("Karte 2 — Mitte", java.awt.Label.CENTER)
    card2.background = .green
    card2.foreground = .white
    let card3 = java.awt.Label("Karte 3 — Ende",  java.awt.Label.CENTER)
    card3.background = .red
    card3.foreground = .white

    cardBox.add(card1, "1")
    cardBox.add(card2, "2")
    cardBox.add(card3, "3")

    add(cardBox, java.awt.BorderLayout.CENTER)

    // Navigationsleiste
    let nav = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER, 4, 2))
    let prevBtn = java.awt.Button("◀")
    prevBtn.setPreferredSize(java.awt.Dimension(36, 22))
    prevBtn.addActionListener(CardNavListener(cards: cards, box: cardBox, dir: -1))
    let nextBtn = java.awt.Button("▶")
    nextBtn.setPreferredSize(java.awt.Dimension(36, 22))
    nextBtn.addActionListener(CardNavListener(cards: cards, box: cardBox, dir: 1))
    nav.add(prevBtn)
    nav.add(nextBtn)
    nav.setPreferredSize(java.awt.Dimension(100, 28))
    add(nav, java.awt.BorderLayout.SOUTH)
  }
}

@MainActor
final class CardNavListener: java.awt.event.ActionListener {
  private let cards: java.awt.CardLayout
  private let box:   java.awt.Panel
  private let dir:   Int   // -1 = previous, +1 = next
  init(cards: java.awt.CardLayout, box: java.awt.Panel, dir: Int) {
    self.cards = cards; self.box = box; self.dir = dir
  }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if dir > 0 { cards.next(box) } else { cards.previous(box) }
  }
}

/// Draws a 5×2 colour grid — demonstrates Canvas.paint().
@MainActor
final class ColourGridCanvas: java.awt.Canvas {

  private let colours: [java.awt.Color] = [
    .red, .green, .blue, .yellow, .cyan,
    .magenta, .orange, .pink, .white, .lightGray
  ]

  override func paint(_ g: java.awt.Graphics) {
    let cols  = 5
    let cellW = bounds.width  / cols
    let cellH = bounds.height / 2
    for (i, colour) in colours.enumerated() {
      g.setColor(colour)
      g.fillRect(bounds.x + (i % cols) * cellW,
                 bounds.y + (i / cols) * cellH,
                 cellW, cellH)
    }
    g.setColor(.black)
    g.drawRect(bounds.x, bounds.y, bounds.width - 1, bounds.height - 1)
  }
}

// ---------------------------------------------------------------------------
// MARK: - Shared UI builder
// ---------------------------------------------------------------------------

@MainActor
func buildShowcase(width: Int, height: Int) -> java.awt.Frame {

  let frame = java.awt.Frame("JavApi⁴Swift – AWT Showcase")
  frame.setSize(width, height)
  frame.setMinimumSize(java.awt.Dimension(380, 280))
  frame.setLayout(java.awt.BorderLayout())

  // ── Höhenaufteilung ──────────────────────────────────────────────────────
  // Alle Höhen sind hier zentral definiert; centerH ergibt sich automatisch.
  let northH    = 40
  let controlsH = 90   // oberer SOUTH-Block: FlowLayout mit Widgets
  let demosH    = 60   // unterer SOUTH-Block: GridLayout + CardLayout Demo
  let southH    = controlsH + demosH
  let centerH   = height - northH - southH

  // ── NORTH: title label ───────────────────────────────────────────────────
  let title = java.awt.Label(
    "Panel · Canvas · Button · Checkbox · TextField · Label · TextArea · Scrollbar · ScrollPane · Choice · List",
    java.awt.Label.CENTER)
  title.setPreferredSize(java.awt.Dimension(width, northH))
  title.setMinimumSize(java.awt.Dimension(200, 30))
  frame.add(title, java.awt.BorderLayout.NORTH)

  // ── CENTER: split view — ScrollPane+Canvas (left) + TextArea (right) ───────
  let centerPanel = java.awt.Panel(java.awt.BorderLayout())
  // CENTER im äußeren BorderLayout füllt den verbleibenden Platz automatisch

  // ColourGridCanvas (doppelte Höhe) — bounds bestimmen den virtuellen Inhalt der ScrollPane
  let bigCanvas = ColourGridCanvas()
  bigCanvas.bounds = java.awt.Rectangle(0, 0, width / 2, centerH * 2)

  // PopupMenu auf dem Canvas
  let canvasPopup = java.awt.PopupMenu("Canvas")
  let copyItem = java.awt.MenuItem("Kopieren")
  copyItem.addActionListener(ShowcaseActionListener())
  let pasteItem = java.awt.MenuItem("Einfügen")
  pasteItem.addActionListener(ShowcaseActionListener())
  canvasPopup.add(copyItem)
  canvasPopup.add(pasteItem)
  canvasPopup.addSeparator()
  let quitFromPopup = java.awt.MenuItem("Beenden")
  quitFromPopup.addActionListener(ShowcaseActionListener())
  canvasPopup.add(quitFromPopup)
  bigCanvas.popupMenu = canvasPopup

  // ScrollPane als WEST im centerPanel: Breite fix, Höhe vom BorderLayout gesetzt
  let scrollPane = java.awt.ScrollPane()
  scrollPane.setPreferredSize(java.awt.Dimension(width / 2, centerH))
  scrollPane.setMinimumSize(java.awt.Dimension(80, 60))
  scrollPane.add(bigCanvas)
  centerPanel.add(scrollPane, java.awt.BorderLayout.WEST)

  // TextArea füllt CENTER — kein explizites preferredSize nötig
  let textArea = java.awt.TextArea("Edit me here…\nLine 2\nLine 3", 5, 20)
  centerPanel.add(textArea, java.awt.BorderLayout.CENTER)

  // PolygonCanvas rechts im centerPanel
  let polyCanvas = PolygonCanvas()
  polyCanvas.setPreferredSize(java.awt.Dimension(80, centerH))
  polyCanvas.setMinimumSize(java.awt.Dimension(60, 60))
  centerPanel.add(polyCanvas, java.awt.BorderLayout.EAST)

  frame.add(centerPanel, java.awt.BorderLayout.CENTER)

  // ── EAST: standalone vertical Scrollbar — Breite fix per preferredSize ───
  let scrollbar = java.awt.Scrollbar(java.awt.Scrollbar.VERTICAL,
                                     value: 0, visible: 20,
                                     minimum: 0, maximum: 100)
  scrollbar.setPreferredSize(java.awt.Dimension(18, centerH))
  scrollbar.setMinimumSize(java.awt.Dimension(12, 40))
  frame.add(scrollbar, java.awt.BorderLayout.EAST)

  // ── SOUTH: controls panel — Höhe fix per preferredSize ───────────────────
  let controls = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 8, 4))
  controls.setPreferredSize(java.awt.Dimension(width, controlsH))
  controls.setMinimumSize(java.awt.Dimension(200, 60))

  // Button
  let btn = java.awt.Button("Click me")
  btn.setPreferredSize(java.awt.Dimension(80, 28))
  btn.setMinimumSize(java.awt.Dimension(50, 22))
  btn.addActionListener(ShowcaseActionListener())
  controls.add(btn)

  // TextField
  let field = java.awt.TextField("Type here…", columns: 12)
  field.setPreferredSize(java.awt.Dimension(140, 28))
  field.setMinimumSize(java.awt.Dimension(60, 22))
  controls.add(field)

  // Checkboxes
  let chkListener = ShowcaseItemListener(label: "Checkbox")

  let chk1 = java.awt.Checkbox("Bold")
  chk1.setPreferredSize(java.awt.Dimension(60, 24))
  chk1.addItemListener(chkListener)
  controls.add(chk1)

  let chk2 = java.awt.Checkbox("Italic", state: true)
  chk2.setPreferredSize(java.awt.Dimension(60, 24))
  chk2.addItemListener(chkListener)
  controls.add(chk2)

  // Radio buttons (CheckboxGroup)
  let group = java.awt.CheckboxGroup()
  let rbListener = ShowcaseItemListener(label: "RadioButton")

  let rb1 = java.awt.Checkbox("Small",  state: true,  group: group)
  rb1.setPreferredSize(java.awt.Dimension(65, 24))
  rb1.addItemListener(rbListener)
  controls.add(rb1)

  let rb2 = java.awt.Checkbox("Medium", state: false, group: group)
  rb2.setPreferredSize(java.awt.Dimension(75, 24))
  rb2.addItemListener(rbListener)
  controls.add(rb2)

  let rb3 = java.awt.Checkbox("Large",  state: false, group: group)
  rb3.setPreferredSize(java.awt.Dimension(65, 24))
  rb3.addItemListener(rbListener)
  controls.add(rb3)

  // Choice (drop-down)
  let choice = java.awt.Choice()
  choice.add("Apple")
  choice.add("Banana")
  choice.add("Cherry")
  choice.add("Durian")
  choice.setPreferredSize(java.awt.Dimension(100, 24))
  choice.setMinimumSize(java.awt.Dimension(60, 22))
  choice.addItemListener(ShowcaseItemListener(label: "Choice"))
  controls.add(choice)

  // List (scrollable, single-select, 3 sichtbare Zeilen — kompakter für SOUTH)
  let list = java.awt.List(3, false)
  list.add("Red")
  list.add("Green")
  list.add("Blue")
  list.add("Yellow")
  list.add("Cyan")
  list.add("Magenta")
  list.setPreferredSize(java.awt.Dimension(90, 62))
  list.setMinimumSize(java.awt.Dimension(60, 40))
  list.addItemListener(ShowcaseItemListener(label: "List"))
  list.addActionListener(ShowcaseActionListener())
  controls.add(list)

  // FileDialog — Öffnen
  let openBtn = java.awt.Button("Open…")
  openBtn.setPreferredSize(java.awt.Dimension(70, 28))
  openBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
  controls.add(openBtn)

  // FileDialog — Speichern
  let saveBtn = java.awt.Button("Save…")
  saveBtn.setPreferredSize(java.awt.Dimension(70, 28))
  saveBtn.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
  controls.add(saveBtn)

  // ── GridLayout + CardLayout Demo unten ───────────────────────────────────
  let southPanel = java.awt.Panel(java.awt.BorderLayout())
  southPanel.setPreferredSize(java.awt.Dimension(width, southH))
  southPanel.setMinimumSize(java.awt.Dimension(200, 100))
  southPanel.add(controls, java.awt.BorderLayout.NORTH)

  let demosPanel = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 6, 4))
  demosPanel.setPreferredSize(java.awt.Dimension(width, demosH))

  // GridLayout-Demo
  let gridPanel = makeGridPanel(width: 180, height: demosH - 4)
  demosPanel.add(gridPanel)

  // CardLayout-Demo
  let cardPanel = CardDemoPanel()
  cardPanel.setPreferredSize(java.awt.Dimension(150, demosH - 4))
  cardPanel.setMinimumSize(java.awt.Dimension(100, 40))
  demosPanel.add(cardPanel)

  // Cursor-Demo
  let cursorPanel = CursorDemoPanel()
  cursorPanel.setPreferredSize(java.awt.Dimension(170, demosH - 4))
  cursorPanel.setMinimumSize(java.awt.Dimension(100, 40))
  demosPanel.add(cursorPanel)

  southPanel.add(demosPanel, java.awt.BorderLayout.CENTER)

  frame.add(southPanel, java.awt.BorderLayout.SOUTH)

  // ── MenuBar ───────────────────────────────────────────────────────────────
  let menuBar = java.awt.MenuBar()

  // Datei-Menü
  let fileMenu = java.awt.Menu("Datei")
  let openItem = java.awt.MenuItem("Öffnen…",
    java.awt.MenuShortcut(79))   // Cmd+O
  openItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.LOAD))
  let saveItem = java.awt.MenuItem("Speichern…",
    java.awt.MenuShortcut(83))   // Cmd+S
  saveItem.addActionListener(FileDialogListener(frame: frame, mode: java.awt.FileDialog.SAVE))
  fileMenu.add(openItem)
  fileMenu.add(saveItem)
  fileMenu.addSeparator()
  let quitItem = java.awt.MenuItem("Beenden",
    java.awt.MenuShortcut(81))   // Cmd+Q
  quitItem.addActionListener(ShowcaseActionListener())
  fileMenu.add(quitItem)
  menuBar.add(fileMenu)

  // Ansicht-Menü mit CheckboxMenuItem
  let viewMenu = java.awt.Menu("Ansicht")
  let toolbarItem = java.awt.CheckboxMenuItem("Werkzeugleiste", true)
  toolbarItem.addItemListener(ShowcaseItemListener(label: "CheckboxMenuItem"))
  viewMenu.add(toolbarItem)
  viewMenu.addSeparator()

  // Untermenü
  let zoomMenu = java.awt.Menu("Zoom")
  for label in ["25 %", "50 %", "100 %", "200 %"] {
    let zi = java.awt.MenuItem(label)
    zi.addActionListener(ShowcaseActionListener())
    zoomMenu.add(zi)
  }
  viewMenu.add(zoomMenu)
  menuBar.add(viewMenu)

  // Hilfe-Menü
  let helpMenu = java.awt.Menu("Hilfe")
  let aboutItem = java.awt.MenuItem("Über JavApi⁴Swift…")
  aboutItem.addActionListener(AboutListener(owner: frame))
  helpMenu.add(aboutItem)
  menuBar.setHelpMenu(helpMenu)

  frame.setMenuBar(menuBar)

  // WindowListener — gibt Lebenszyklusereignisse auf der Konsole aus
  frame.addWindowListener(ShowcaseWindowListener())

  return frame
}

/// Simple ActionListener that prints to console — beendet die App bei "Beenden".
@MainActor
final class ShowcaseActionListener: java.awt.event.ActionListener {
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    print("Action: \(e.actionCommand)")
    if e.actionCommand == "Beenden" {
      terminateApp()
    }
  }
}

@MainActor
func terminateApp() {
#if canImport(AppKit)
  NSApp.terminate(nil)
#else
  exit(0)
#endif
}

/// ItemListener für Choice und List — gibt Auswahl auf der Konsole aus.
@MainActor
final class ShowcaseItemListener: java.awt.event.ItemListener {
  private let label: String
  init(label: String) { self.label = label }
  func itemStateChanged(_ e: java.awt.event.ItemEvent) {
    let state = e.stateChange == java.awt.event.ItemEvent.SELECTED ? "selected" : "deselected"
    let item  = e.item as? String ?? "?"
    print("\(label): \(item) \(state)")
  }
}

/// WindowListener — gibt Fenster-Lebenszyklusereignisse auf der Konsole aus.
@MainActor
final class ShowcaseWindowListener: java.awt.event.WindowListener {
  func windowOpened     (_ e: java.awt.event.WindowEvent) { print("Window: opened")      }
  func windowClosing    (_ e: java.awt.event.WindowEvent) { print("Window: closing")     }
  func windowClosed     (_ e: java.awt.event.WindowEvent) { print("Window: closed")      }
  func windowIconified  (_ e: java.awt.event.WindowEvent) { print("Window: iconified")   }
  func windowDeiconified(_ e: java.awt.event.WindowEvent) { print("Window: deiconified") }
  func windowActivated  (_ e: java.awt.event.WindowEvent) { print("Window: activated")   }
  func windowDeactivated(_ e: java.awt.event.WindowEvent) { print("Window: deactivated") }
}

/// Öffnet einen FileDialog und gibt das Ergebnis auf der Konsole aus.
@MainActor
final class FileDialogListener: java.awt.event.ActionListener {
  private weak var frame: java.awt.Frame?
  private let mode: Int

  init(frame: java.awt.Frame, mode: Int) {
    self.frame = frame
    self.mode  = mode
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let title = mode == java.awt.FileDialog.LOAD ? "Datei öffnen" : "Datei speichern"
    let fd    = java.awt.FileDialog(frame, title, mode)
    fd.setVisible(true)
    if let file = fd.getFile(), let dir = fd.getDirectory() {
      print("FileDialog: \(dir)\(file)")
    } else {
      print("FileDialog: abgebrochen")
    }
  }
}

// ---------------------------------------------------------------------------
// MARK: - Logo-Canvas (zeichnet das J4-Logo via BufferedImage)
// ---------------------------------------------------------------------------

/// Zeichnet das JavApi⁴Swift-Logo programmatisch als BufferedImage.
@MainActor
final class LogoCanvas: java.awt.Canvas {

  /// Gecachtes Image — wird beim ersten paint() erzeugt.
  private var logoImage: java.awt.image.BufferedImage? = nil

  override func paint(_ g: java.awt.Graphics) {
    let w = bounds.width, h = bounds.height
    guard w > 0, h > 0 else { return }

    // Image beim ersten Aufruf erzeugen
    if logoImage == nil || logoImage!.width != w || logoImage!.height != h {
      logoImage = buildLogo(width: w, height: h)
    }
    if let img = logoImage {
      g.drawImage(img, bounds.x, bounds.y, w, h)
    }
  }

  /// Zeichnet das Logo (blaues Oval, weißes „J4") in ein BufferedImage.
  private func buildLogo(width: Int, height: Int) -> java.awt.image.BufferedImage {
    let img = java.awt.image.BufferedImage(width, height)
    let cx = width / 2, cy = height / 2
    let rx = width / 2 - 2, ry = height / 2 - 2

    // Hintergrund weiß
    img.fill(.white)

    // Blaues Oval
    let blue = argb(52, 120, 246)
    for py in 0 ..< height {
      for px in 0 ..< width {
        let dx = Double(px - cx) / Double(rx)
        let dy = Double(py - cy) / Double(ry)
        if dx*dx + dy*dy <= 1.0 {
          img.setRGB(px, py, blue)
        }
      }
    }

    // Weißes „J4" als Pixelstriche
    let white = argb(255, 255, 255)
    let t = max(2, width / 16)   // Strichstärke

    func fill(_ fx: Double, _ fy: Double, _ fw: Double, _ fh: Double) {
      let x0 = Int(fx * Double(width)),  y0 = Int(fy * Double(height))
      let x1 = Int((fx+fw) * Double(width)), y1 = Int((fy+fh) * Double(height))
      for yy in max(0,y0) ..< min(height,y1) {
        for xx in max(0,x0) ..< min(width,x1) {
          img.setRGB(xx, yy, white)
        }
      }
    }

    let tf = Double(t) / Double(width)
    // J: senkrechter Strich, Haken links unten
    fill(0.38, 0.18, tf*2, 0.45)
    fill(0.22, 0.55, 0.18, tf*2)
    fill(0.22, 0.45, tf*2, 0.12)
    // 4: linker Schenkel, Querbalken, rechter Schenkel
    fill(0.55, 0.18, tf*2, 0.30)
    fill(0.55, 0.44, 0.22, tf*2)
    fill(0.73, 0.18, tf*2, 0.50)

    return img
  }

  private func argb(_ r: Int, _ g: Int, _ b: Int) -> Int {
    (255 << 24) | (r << 16) | (g << 8) | b
  }
}

// ---------------------------------------------------------------------------
// MARK: - AboutListener öffnet den Über-Dialog
// ---------------------------------------------------------------------------

@MainActor
final class AboutListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    let dialog = java.awt.Dialog(owner, "Über JavApi⁴Swift", true)
    dialog.setLayout(java.awt.BorderLayout())
    dialog.setPreferredSize(java.awt.Dimension(320, 260))
    dialog.bounds = java.awt.Rectangle(0, 0, 320, 260)

    // Logo oben
    let logo = LogoCanvas()
    logo.setPreferredSize(java.awt.Dimension(320, 140))
    dialog.add(logo, java.awt.BorderLayout.NORTH)

    // Text mittig
    let info = java.awt.Label("JavApi⁴Swift  •  Java AWT für Swift", java.awt.Label.CENTER)
    info.setPreferredSize(java.awt.Dimension(320, 40))
    dialog.add(info, java.awt.BorderLayout.CENTER)

    // Schließen-Button unten
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 30))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
    south.setPreferredSize(java.awt.Dimension(320, 50))
    south.add(closeBtn)
    dialog.add(south, java.awt.BorderLayout.SOUTH)

    closeBtn.addActionListener(DialogCloseListener(dialog: dialog))

    dialog.validate()
    dialog.setVisible(true)
  }
}

@MainActor
final class DialogCloseListener: java.awt.event.ActionListener {
  private weak var dialog: java.awt.Dialog?
  init(dialog: java.awt.Dialog) { self.dialog = dialog }
  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    dialog?.dispose()
  }
}

// ---------------------------------------------------------------------------
// MARK: - Cursor demo panel
// ---------------------------------------------------------------------------

/// Demonstrates java.awt.Cursor — cycles through all predefined cursor types.
@MainActor
final class CursorDemoPanel: java.awt.Panel {

  private static let cursors: [(Int, String)] = [
    (java.awt.Cursor.DEFAULT_CURSOR,   "DEFAULT"),
    (java.awt.Cursor.CROSSHAIR_CURSOR, "CROSSHAIR"),
    (java.awt.Cursor.TEXT_CURSOR,      "TEXT"),
    (java.awt.Cursor.WAIT_CURSOR,      "WAIT"),
    (java.awt.Cursor.HAND_CURSOR,      "HAND"),
    (java.awt.Cursor.MOVE_CURSOR,      "MOVE"),
    (java.awt.Cursor.N_RESIZE_CURSOR,  "N_RESIZE"),
    (java.awt.Cursor.S_RESIZE_CURSOR,  "S_RESIZE"),
    (java.awt.Cursor.E_RESIZE_CURSOR,  "E_RESIZE"),
    (java.awt.Cursor.W_RESIZE_CURSOR,  "W_RESIZE"),
    (java.awt.Cursor.NE_RESIZE_CURSOR, "NE_RESIZE"),
    (java.awt.Cursor.NW_RESIZE_CURSOR, "NW_RESIZE"),
    (java.awt.Cursor.SE_RESIZE_CURSOR, "SE_RESIZE"),
    (java.awt.Cursor.SW_RESIZE_CURSOR, "SW_RESIZE"),
  ]

  private var currentIndex = 0
  private let nameLabel: java.awt.Label

  override init() {
    nameLabel = java.awt.Label("Cursor: DEFAULT", java.awt.Label.CENTER)
    super.init()
    setLayout(java.awt.BorderLayout())

    nameLabel.setPreferredSize(java.awt.Dimension(160, 24))
    add(nameLabel, java.awt.BorderLayout.CENTER)

    let nav = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER, 4, 2))
    let prevBtn = java.awt.Button("◀")
    prevBtn.setPreferredSize(java.awt.Dimension(32, 22))
    prevBtn.addActionListener(CursorNavListener(panel: self, dir: -1))
    let nextBtn = java.awt.Button("▶")
    nextBtn.setPreferredSize(java.awt.Dimension(32, 22))
    nextBtn.addActionListener(CursorNavListener(panel: self, dir: +1))
    nav.add(prevBtn)
    nav.add(nextBtn)
    nav.setPreferredSize(java.awt.Dimension(80, 28))
    add(nav, java.awt.BorderLayout.SOUTH)
  }

  func step(_ dir: Int) {
    currentIndex = (currentIndex + dir + CursorDemoPanel.cursors.count) % CursorDemoPanel.cursors.count
    let (type, name) = CursorDemoPanel.cursors[currentIndex]
    setCursor(java.awt.Cursor.getPredefinedCursor(type))
    nameLabel.setText("Cursor: \(name)")
    print("Cursor changed to: \(java.awt.Cursor.getPredefinedCursor(type).getName())")
  }
}

@MainActor
final class CursorNavListener: java.awt.event.ActionListener {
  private weak var panel: CursorDemoPanel?
  private let dir: Int
  init(panel: CursorDemoPanel, dir: Int) { self.panel = panel; self.dir = dir }
  func actionPerformed(_ e: java.awt.event.ActionEvent) { panel?.step(dir) }
}

// ---------------------------------------------------------------------------
// MARK: - Platform entry points
// ---------------------------------------------------------------------------

#if os(macOS)
import AppKit
import SwiftUI

@main
struct AWTShowcase: App {
  @NSApplicationDelegateAdaptor(AWTShowcaseDelegate.self) var appDelegate
  var body: some Scene {
    Settings { Text("JavApi⁴Swift AWT Showcase").padding() }
  }
}

@MainActor
final class AWTShowcaseDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    AWTWindowHost.shared.openNewWindow(for: buildShowcase(width: 520, height: 420))
  }
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

#elseif canImport(UIKit)
import SwiftUI

@main
struct AWTShowcase: App {
  @StateObject private var host = AWTWindowHost.shared
  var body: some Scene {
    WindowGroup {
      AWTMultiWindowView()
        .environmentObject(host)
        .task {
          let frame = buildShowcase(width: 390, height: 700)
          frame.validate()
          frame.setVisible(true)
        }
    }
  }
}

#else
// Linux / headless
@main
struct AWTShowcase {
  static func main() {
    let frame = buildShowcase(width: 520, height: 420)
    frame.validate()
    frame.setVisible(true)
    print("AWTShowcase headless: Frame > BorderLayout > Panel(NORTH) + Canvas(CENTER) + Panel(SOUTH)")
    print("  SOUTH contains: Button, TextField, 2 Checkboxes, 3 RadioButtons")
  }
}
#endif
