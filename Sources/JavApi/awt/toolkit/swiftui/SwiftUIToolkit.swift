/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS) && canImport(AppKit)
import AppKit
#elseif os(watchOS) && canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

extension java.awt.toolkit.swiftui {

  /// SwiftUI-backed toolkit for Apple platforms (macOS, iOS, tvOS, visionOS).
  ///
  /// - Note: Delegates window lifecycle to `_SwiftUIWindowHost`.
  @MainActor
  public final class SwiftUIToolkit: java.awt.Toolkit {

    public static let shared = SwiftUIToolkit()

    private override init() {}

    public override func show(_ window: java.awt.Window) {
#if os(macOS)
      // FileDialog verwaltet seinen eigenen nativen Panel in setVisible —
      // kein _SwiftUIWindowHost-Fenster nötig.
      if window is java.awt.FileDialog { return }
      if let dialog = window as? java.awt.Dialog {
        _SwiftUIWindowHost.shared.openDialog(dialog)
        return
      }
      _SwiftUIWindowHost.shared.openNewWindow(for: window)
#else
      _SwiftUIWindowHost.shared.show(window)
#endif
    }

    public override func hide(_ window: java.awt.Window) {
#if os(macOS)
      if let dialog = window as? java.awt.Dialog {
        _SwiftUIWindowHost.shared.closeDialog(dialog)
        return
      }
#endif
      _SwiftUIWindowHost.shared.hide(window)
    }

    public override func attachMenuBar(_ menuBar: java.awt.MenuBar?, to frame: java.awt.Frame) {
#if os(macOS)
      _SwiftUIWindowHost.shared.attachMenuBar(menuBar, to: frame)
#endif
    }

    public override func showPopupMenu(_ menu: java.awt.PopupMenu, origin: java.awt.Component, x: Int, y: Int) {
#if os(macOS)
      menu._showNative(origin: origin, x: x, y: y)
#endif
    }

    public override func isFocusOwner(_ component: java.awt.Component) -> Bool {
      return _SwiftUIFocusManager.shared.focusOwner === component
    }

    public override func closeDialog(_ dialog: java.awt.Dialog) {
#if os(macOS)
      _SwiftUIWindowHost.shared.closeDialog(dialog)
#else
      super.closeDialog(dialog)
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Application lifecycle
    // -------------------------------------------------------------------------

    /// `true` once `runEventLoop()` has been called — prevents double-starting
    /// the AppKit / UIKit event loop.
    private var eventLoopStarted = false

    /// Java 1.0–style entry point: shows `frame` and starts the event loop.
    /// - Since: JavaApi > 0.19.1
    public override func run(frame: java.awt.Frame) {
      frame.setVisible(true)
      runEventLoop()
    }

    /// Drains pending `EventQueue` runnables and starts the AppKit / UIKit
    /// event loop (once only).
    ///
    /// - Since: JavaApi > 0.19.1
    public override func runEventLoop() {
      guard !eventLoopStarted else { return }
      eventLoopStarted = true
      java.awt.EventQueue.drainAndMarkRunning()
      _startPlatformLoop()
    }

    /// Platform-specific loop entry — separated so subclasses can override
    /// just this part without duplicating the guard logic.
    @MainActor
    private func _startPlatformLoop() {
#if os(macOS) && canImport(AppKit)
      let delegate = _AWTLoopDelegate()
      NSApplication.shared.delegate = delegate
      NSApplication.shared.setActivationPolicy(.regular)
      NSApp.run()
#elseif canImport(UIKit) && !os(watchOS)
      // UIApplicationMain does not return; store delegate class name.
      UIApplicationMain(
        CommandLine.argc, CommandLine.unsafeArgv,
        nil, NSStringFromClass(_AWTUILoopDelegate.self))
#endif
      // visionOS / watchOS / headless: no blocking loop needed
    }

    /// Terminates the application via `NSApp.terminate(nil)` (macOS) or
    /// `UIApplication.shared.perform(#selector(NSXPCConnection.suspend))`
    /// (iOS/tvOS). Falls back to `exit(0)` on all other Apple platforms.
    ///
    /// - Since: JavaApi > 0.19.1
    public override func terminate() {
#if os(macOS) && canImport(AppKit)
      AppKit.NSApp.terminate(nil)
#elseif canImport(UIKit) && !os(watchOS)
      UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
      // Give the OS a moment, then force-exit if needed
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
#else
      exit(0)
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Screen properties
    // -------------------------------------------------------------------------

    /// Returns the screen size in pixels using `NSScreen` (macOS) or `UIScreen` (iOS/tvOS).
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenSize() -> java.awt.Dimension {
#if os(macOS) && canImport(AppKit)
      if let screen = AppKit.NSScreen.main {
        let frame = screen.frame
        return java.awt.Dimension(Int(frame.width), Int(frame.height))
      }
      return java.awt.Dimension(0, 0)
#elseif os(watchOS) && canImport(WatchKit)
      let bounds = WKInterfaceDevice.current().screenBounds
      return java.awt.Dimension(Int(bounds.width), Int(bounds.height))
#elseif os(visionOS)
      // visionOS has no fixed screen — return (0,0) as headless sentinel
      return java.awt.Dimension(0, 0)
#elseif canImport(UIKit)
      let bounds = UIScreen.main.bounds
      return java.awt.Dimension(Int(bounds.width), Int(bounds.height))
#else
      return java.awt.Dimension(0, 0)
#endif
    }

    /// Returns the screen resolution in dots-per-inch.
    ///
    /// The base DPI follows the Java AWT convention per platform:
    /// - **macOS**: baseline 72 dpi (historical PostScript/Mac standard),
    ///   multiplied by `backingScaleFactor` (2.0 on Retina → 144 dpi).
    /// - **iOS / tvOS**: baseline 160 dpi (Apple's point-per-inch reference
    ///   for non-Retina iPhone), multiplied by `UIScreen.main.scale`
    ///   (2.0 or 3.0 on Retina → 320 / 480 dpi).
    /// - **watchOS**: baseline 160 dpi × `WKInterfaceDevice.screenScale`.
    /// - **visionOS**: no physical screen; returns a reasonable 96 dpi default.
    ///
    /// The differing baselines (72 vs. 160) reflect the physical pixel densities
    /// of the respective device families and match what `java.awt.Toolkit`
    /// implementations return on those platforms.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getScreenResolution() -> Int {
#if os(macOS) && canImport(AppKit)
      let scale = AppKit.NSScreen.main?.backingScaleFactor ?? 1.0
      return Int(72.0 * scale)
#elseif os(watchOS) && canImport(WatchKit)
      let scale = WKInterfaceDevice.current().screenScale
      return Int(160.0 * scale)
#elseif os(visionOS)
      return 96   // no physical screen concept on visionOS
#elseif canImport(UIKit)
      let scale = UIScreen.main.scale
      return Int(160.0 * scale)
#else
      return 72
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Font list & metrics
    // -------------------------------------------------------------------------

    /// Returns system font family names via AppKit (macOS) or UIKit (iOS).
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getFontList() -> [String] {
#if os(macOS) && canImport(AppKit)
      return AppKit.NSFontManager.shared.availableFontFamilies
#elseif canImport(UIKit)
      return UIFont.familyNames.sorted()
#else
      return super.getFontList()
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Image loading
    // -------------------------------------------------------------------------

    /// Loads a named image from the module bundle via AppKit (macOS) or UIKit (iOS/tvOS).
    ///
    /// On macOS the lookup order is:
    /// 1. `Assets.xcassets/AppIcon.appiconset/<name>.png` inside `Bundle.module`
    /// 2. `NSImage(named:)` — works for app-bundle assets and system images
    ///
    /// The `NSImage` / `UIImage` is converted to a `java.awt.image.BufferedImage`
    /// backed by a CGImage so that `Graphics.drawImage` can render it.
    ///
    /// - Since: JavaApi > 0.19.1
    public override func loadImage(named name: String) -> java.awt.Image? {
#if os(macOS) && canImport(AppKit)
      let nsImg: NSImage? = {
        // Build the full list of bundles to search:
        // 1. All already-loaded bundles (covers .app deployments)
        var candidates: [Bundle] = Bundle.allBundles + Bundle.allFrameworks
        candidates.append(Bundle.main)
        candidates.append(Bundle(for: SwiftUIToolkit.self))

        // 2. Search directories where SPM/Xcode place resource bundles:
        //    - swift run:  next to executable (.build/.../debug/)
        //    - .app bundle: Contents/Resources/
        let execURL = URL(fileURLWithPath: CommandLine.arguments[0])
          .deletingLastPathComponent()
        var searchDirs: [URL] = [execURL]
        // .app bundle: go up from Contents/MacOS → Contents/Resources
        let resourcesURL = execURL
          .deletingLastPathComponent()          // Contents/
          .appendingPathComponent("Resources")
        searchDirs.append(resourcesURL)
        // Also try Bundle.main.resourceURL (covers both cases)
        if let mainResources = Bundle.main.resourceURL {
          searchDirs.append(mainResources)
        }

        for dir in searchDirs {
          guard let enumerator = FileManager.default.enumerator(
              at: dir,
              includingPropertiesForKeys: nil,
              options: [.skipsSubdirectoryDescendants]) else { continue }
          for case let url as URL in enumerator
          where url.pathExtension == "bundle" {
            if let b = Bundle(url: url) {
              candidates.append(b)
            }
          }
        }

        let subdirs = [
          "Assets.xcassets/AppIcon.appiconset",
          "Assets.xcassets",
          "",
        ]
        for bundle in candidates {
          for subdir in subdirs {
            let url: URL?
            if subdir.isEmpty {
              url = bundle.url(forResource: name, withExtension: "png")
            } else {
              url = bundle.url(forResource: name, withExtension: "png",
                               subdirectory: subdir)
            }
            if let url, let img = NSImage(contentsOf: url) {
              return img
            }
          }
        }
        // Final fallback: named image / asset catalog
        return NSImage(named: name)
      }()
      guard let nsImg,
            let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil)
      else { return nil }
      return java.awt.image.BufferedImage(cgImage: cgImg)
#elseif canImport(UIKit)
      guard let uiImg = UIImage(named: name),
            let cgImg = uiImg.cgImage
      else { return nil }
      return java.awt.image.BufferedImage(cgImage: cgImg)
#else
      return nil
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Printing
    // -------------------------------------------------------------------------

    /// Shows the native print panel and, if confirmed, returns a `_SwiftUIPrintJob`
    /// that renders each page into a CoreGraphics PDF context.
    ///
    /// The resulting PDF is opened in Preview.app when `PrintJob.end()` is called.
    ///
    /// - Since: JavaApi > 0.19.1 (Java 1.1)
    public override func getPrintJob(_ frame: java.awt.Frame, _ jobtitle: String, _ props: java.util.Properties?) -> java.awt.PrintJob? {
#if os(macOS) && canImport(AppKit)
      let printInfo = NSPrintInfo.shared
      printInfo.jobDisposition = NSPrintInfo.JobDisposition.preview

      let panel = NSPrintPanel()
      panel.options = [.showsCopies, .showsPaperSize, .showsOrientation]

      guard panel.runModal(with: printInfo) == NSApplication.ModalResponse.OK.rawValue else { return nil }

      let paper = printInfo.paperSize
      return _SwiftUIPrintJob(pageWidth: paper.width, pageHeight: paper.height)
#else
      return nil
#endif
    }

    // -------------------------------------------------------------------------
    // MARK: Color model
    // -------------------------------------------------------------------------

    /// Returns the screen color model.
    ///
    /// Modern Apple displays use 32-bit ARGB; we return the standard RGB default.
    /// - Since: JavaApi > 0.19.1 (Java 1.0)
    public override func getColorModel() -> java.awt.image.ColorModel {
      return java.awt.image.ColorModel.getRGBdefault()
    }

    // -------------------------------------------------------------------------
    // MARK: Clipboard
    // -------------------------------------------------------------------------

    /// Returns the native Apple clipboard provider.
    ///
    /// - macOS: backed by `NSPasteboard.general`
    /// - iOS/tvOS: backed by `UIPasteboard.general`
    /// - watchOS: falls back to in-memory headless provider (no pasteboard API)
    public override func _makeClipboardProvider() -> any java.awt.toolkit.ClipboardProvider {
#if canImport(AppKit)
      return java.awt.toolkit._AppKitClipboardProvider()
#elseif canImport(UIKit) && !os(watchOS)
      return java.awt.toolkit._UIKitClipboardProvider()
#else
      return java.awt.toolkit._HeadlessClipboardProvider()
#endif
    }
  }
}

// =============================================================================
// MARK: Internal platform loop delegates
// =============================================================================

#if os(macOS) && canImport(AppKit)
/// AppKit delegate used by `SwiftUIToolkit.runEventLoop()`.
/// Opens the first AWT frame after `NSApp` finishes launching.
@MainActor
private final class _AWTLoopDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
    // EventQueue runnables have already been drained by drainAndMarkRunning()
    // before NSApp.run() was called, so pending frames are already visible.
  }
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}
#endif

#if canImport(UIKit) && !os(watchOS)
/// UIKit delegate used by `SwiftUIToolkit.runEventLoop()` on iOS/tvOS.
@MainActor
private final class _AWTUILoopDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // EventQueue runnables already drained — frames are visible.
    return true
  }
}
#endif

#endif  // canImport(SwiftUI)
