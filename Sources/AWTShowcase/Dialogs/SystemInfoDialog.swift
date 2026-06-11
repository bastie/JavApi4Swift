/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import JavApi

// ---------------------------------------------------------------------------
// MARK: - SystemInfoDialog
// ---------------------------------------------------------------------------

/// Zeigt Systeminformationen: Umgebungsvariablen, Bildschirm und Netzwerk.
@MainActor
final class SystemInfoDialog {

  static func show(owner: java.awt.Frame) {
    let dialog = java.awt.Dialog(owner, "Systeminformationen", true)
    dialog.setLayout(java.awt.BorderLayout())
    dialog.setPreferredSize(java.awt.Dimension(600, 500))
    dialog.setBounds(0, 0, 600, 500)

    // ── Tabs via CardLayout ──────────────────────────────────────────────
    let cardLayout = java.awt.CardLayout()
    let cardPanel  = java.awt.Panel(cardLayout)

    cardPanel.add(makeScreenPanel(),  "Bildschirm")
    cardPanel.add(makeNetworkPanel(), "Netzwerk")
    cardPanel.add(makeEnvPanel(),     "Umgebung")

    // ── Tab-Buttons oben ─────────────────────────────────────────────────
    let tabBar = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.LEFT, 4, 4))
    for title in ["Bildschirm", "Netzwerk", "Umgebung"] {
      let btn = java.awt.Button(title)
      btn.setPreferredSize(java.awt.Dimension(100, 26))
      btn.addActionListener(CardSwitchListener(cardLayout: cardLayout, panel: cardPanel, card: title))
      tabBar.add(btn)
    }
    tabBar.setPreferredSize(java.awt.Dimension(600, 38))

    // ── Schließen-Button unten ───────────────────────────────────────────
    let closeBtn = java.awt.Button("Schließen")
    closeBtn.setPreferredSize(java.awt.Dimension(100, 28))
    closeBtn.addActionListener(DialogCloseListener(dialog: dialog))
    let south = java.awt.Panel(java.awt.FlowLayout(java.awt.FlowLayout.CENTER))
    south.setPreferredSize(java.awt.Dimension(600, 42))
    south.add(closeBtn)

    dialog.add(tabBar,     java.awt.BorderLayout.NORTH)
    dialog.add(cardPanel,  java.awt.BorderLayout.CENTER)
    dialog.add(south,      java.awt.BorderLayout.SOUTH)

    dialog.validate()
    dialog.setVisible(true)
  }

  // ── Bildschirm-Tab ──────────────────────────────────────────────────────

  private static func makeScreenPanel() -> java.awt.Panel {
    let toolkit = java.awt.Toolkit.getDefaultToolkit()
    let size    = toolkit.getScreenSize()
    let dpi     = toolkit.getScreenResolution()

    var lines = [String]()
    lines.append("=== Bildschirminformationen ===")
    lines.append("")
    lines.append("Auflösung:  \(size.width) × \(size.height) px")
    lines.append("DPI:        \(dpi)")
    lines.append("Skalierung: \(String(format: "%.2f", Double(dpi) / 72.0))×  (Basis 72 dpi)")
    lines.append("")
    lines.append("=== Plattform ===")
    lines.append("")
    let osName = (try? java.lang.System.getProperty("os.name")) ?? nil
    lines.append("os.name:    \(osName ?? "(unbekannt)")")
    let osArch = (try? java.lang.System.getProperty("os.arch")) ?? nil
    lines.append("os.arch:    \(osArch ?? "(unbekannt)")")
    lines.append("CPUs:       \(java.lang.Runtime.getRuntime().availableProcessors())")
    let rt = java.lang.Runtime.getRuntime()
    let ramGB = Double(rt.maxMemory()) / 1_073_741_824.0
    let usedMemory = rt.totalMemory()
    let usedStr = usedMemory >= 0
      ? String(format: "%.0f MB genutzt", Double(usedMemory) / 1_048_576.0)
      : "(nicht verfügbar)"
    lines.append("RAM:        \(String(format: "%.1f", ramGB)) GB gesamt, \(usedStr)")

    return makeTextArea(lines.joined(separator: "\n"))
  }

  // ── Netzwerk-Tab ────────────────────────────────────────────────────────

  private static func makeNetworkPanel() -> java.awt.Panel {
    var lines = [String]()
    lines.append("=== Netzwerkinformationen ===")
    lines.append("")

    do {
      let localHost = try java.net.InetAddress.getLocalHost()
      lines.append("Hostname:       \(localHost.getHostName())")
      lines.append("Lokale IP:      \(localHost.getHostAddress())")
    } catch {
      lines.append("Hostname:       (nicht ermittelbar)")
      lines.append("Lokale IP:      (nicht ermittelbar)")
    }

    lines.append("")
    lines.append("=== Bekannte Adressen ===")
    lines.append("")
    let hosts = ["localhost", "loopback"]
    for host in hosts {
      if let addr = try? java.net.InetAddress.getByName(host) {
        lines.append("\(host.padding(toLength: 15, withPad: " ", startingAt: 0)) → \(addr.getHostAddress())")
      }
    }

    lines.append("")
    lines.append("=== System-Proxy-Einstellungen ===")
    lines.append("")
    let proxyKeys = ["http.proxyHost", "http.proxyPort", "https.proxyHost", "https.proxyPort",
                     "ftp.proxyHost",  "ftp.proxyPort",  "socksProxyHost",  "socksProxyPort"]
    for key in proxyKeys {
      let val = java.lang.System.getenv(key) ?? "(nicht gesetzt)"
      lines.append("\(key.padding(toLength: 18, withPad: " ", startingAt: 0)) = \(val)")
    }

    return makeTextArea(lines.joined(separator: "\n"))
  }

  // ── Umgebungsvariablen-Tab ──────────────────────────────────────────────

  private static func makeEnvPanel() -> java.awt.Panel {
    var lines = [String]()
    lines.append("=== Umgebungsvariablen ===")
    lines.append("")
    let env = java.lang.System.getenv()
    for key in env.keys.sorted() {
      let val = env[key] ?? ""
      lines.append("\(key) = \(val)")
    }
    lines.append("")
    lines.append("=== JavApi System Properties ===")
    lines.append("")
    let props = java.lang.System.getProperties()
    let names = props.propertyNames()
    var keys = [String]()
    var mutableNames = names
    while mutableNames.hasMoreElements() {
      if let k = try? mutableNames.nextElement() { keys.append(k) }
    }
    for key in keys.sorted() {
      let raw = props.getProperty(key) ?? ""
      let display = key == "line.separator" ? humanReadable(raw) : raw
      lines.append("\(key) = \(display)")
    }
    return makeTextArea(lines.joined(separator: "\n"))
  }

  // ── Hilfsmethode: Steuerzeichen lesbar machen ───────────────────────────

  private static func humanReadable(_ s: String) -> String {
    s.replacingOccurrences(of: "\r\n", with: "\\r\\n (Windows/CRLF)")
     .replacingOccurrences(of: "\r",   with: "\\r (old macOS/CR)")
     .replacingOccurrences(of: "\n",   with: "\\n (Unix/LF)")
  }

  // ── Hilfsmethode: TextArea-Panel ────────────────────────────────────────

  private static func makeTextArea(_ text: String) -> java.awt.Panel {
    let panel = java.awt.Panel(java.awt.BorderLayout())
    let ta = java.awt.TextArea(text, 20, 70)
    ta.setEditable(false)
    panel.add(ta, java.awt.BorderLayout.CENTER)
    return panel
  }
}

// ---------------------------------------------------------------------------
// MARK: - Listener
// ---------------------------------------------------------------------------

@MainActor
final class CardSwitchListener: java.awt.event.ActionListener {
  private let cardLayout: java.awt.CardLayout
  private weak var panel: java.awt.Panel?
  private let card: String

  init(cardLayout: java.awt.CardLayout, panel: java.awt.Panel, card: String) {
    self.cardLayout = cardLayout
    self.panel = panel
    self.card  = card
  }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let panel { cardLayout.show(panel, card) }
  }
}

@MainActor
final class SystemInfoListener: java.awt.event.ActionListener {
  private weak var owner: java.awt.Frame?
  init(owner: java.awt.Frame) { self.owner = owner }

  func actionPerformed(_ e: java.awt.event.ActionEvent) {
    if let owner { SystemInfoDialog.show(owner: owner) }
  }
}
