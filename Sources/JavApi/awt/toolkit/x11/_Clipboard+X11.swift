/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if os(Linux) || os(FreeBSD)
import Foundation

extension java.awt.toolkit {

  /// X11 / Wayland clipboard backend.
  ///
  /// Supports both X11 and Wayland sessions by detecting the environment at
  /// runtime:
  ///
  /// | Session      | Tool used        | Notes                              |
  /// |--------------|------------------|------------------------------------|
  /// | Wayland      | `wl-copy` / `wl-paste` | via `$WAYLAND_DISPLAY`       |
  /// | X11          | `xclip`          | CLIPBOARD selection atom           |
  /// | X11 fallback | `xsel`           | if `xclip` is not installed        |
  /// | Headless     | in-memory buffer | no display, e.g. CI / server       |
  ///
  /// The tool is located with `/usr/bin/env` so custom `$PATH` installs are
  /// found automatically.  All subprocess calls are synchronous (matching
  /// Java's synchronous `Clipboard` API).
  ///
  /// If none of the tools are available the implementation falls back to
  /// ``_HeadlessClipboardProvider`` so that copy → paste still works
  /// within the running process.
  ///
  /// - Since: JavaApi (Java 1.1 datatransfer)
  public final class _X11ClipboardProvider: ClipboardProvider, @unchecked Sendable {

    // MARK: - Session detection

    private enum Session {
      case wayland, xclip, xsel, headless
    }

    /// Detected once at first use.
    private lazy var session: Session = _detectSession()

    /// In-memory fallback used when no display tool is available.
    private let fallback = java.awt.toolkit.headless._HeadlessClipboardProvider()

    public init() {}

    // MARK: - ClipboardProvider

    public func _getClipboardText() -> String? {
      switch session {
      case .wayland:  return _run(["wl-paste", "--no-newline"])
      case .xclip:    return _run(["xclip", "-selection", "clipboard", "-o"])
      case .xsel:     return _run(["xsel", "--clipboard", "--output"])
      case .headless: return fallback._getClipboardText()
      }
    }

    public func _setClipboardText(_ text: String) {
      switch session {
      case .wayland:
        _pipe(text, to: ["wl-copy"])
      case .xclip:
        _pipe(text, to: ["xclip", "-selection", "clipboard", "-i"])
      case .xsel:
        _pipe(text, to: ["xsel", "--clipboard", "--input"])
      case .headless:
        fallback._setClipboardText(text)
      }
    }

    // MARK: - Session detection

    private func _detectSession() -> Session {
      // Wayland takes priority when both WAYLAND_DISPLAY and wl-copy exist.
      if ProcessInfo.processInfo.environment["WAYLAND_DISPLAY"] != nil,
         _toolExists("wl-copy") {
        return .wayland
      }
      if ProcessInfo.processInfo.environment["DISPLAY"] != nil {
        if _toolExists("xclip") { return .xclip }
        if _toolExists("xsel")  { return .xsel  }
      }
      return .headless
    }

    /// Returns `true` if the named tool can be found via `which`.
    private func _toolExists(_ tool: String) -> Bool {
      _run(["which", tool]) != nil
    }

    // MARK: - Subprocess helpers

    /// Runs a command and returns trimmed stdout, or `nil` on error.
    private func _run(_ args: [String]) -> String? {
      let p = Process()
      p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
      p.arguments     = args
      let out = Pipe()
      p.standardOutput = out
      p.standardError  = Pipe()   // suppress noise
      do {
        try p.run()
        p.waitUntilExit()
      } catch {
        return nil
      }
      guard p.terminationStatus == 0 else { return nil }
      let data = out.fileHandleForReading.readDataToEndOfFile()
      let str  = String(data: data, encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      return str.isEmpty ? nil : str
    }

    /// Writes `text` to the stdin of a command (for clipboard write tools).
    private func _pipe(_ text: String, to args: [String]) {
      let p = Process()
      p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
      p.arguments     = args
      let stdin = Pipe()
      p.standardInput  = stdin
      p.standardOutput = Pipe()   // suppress
      p.standardError  = Pipe()   // suppress
      do {
        try p.run()
      } catch {
        // tool not found — fall back to in-memory
        fallback._setClipboardText(text)
        return
      }
      if let data = text.data(using: .utf8) {
        stdin.fileHandleForWriting.write(data)
      }
      stdin.fileHandleForWriting.closeFile()
      p.waitUntilExit()
    }
  }
}
#endif
