/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)

extension java.awt {

  /// SwiftUI-backed toolkit for Apple platforms (macOS, iOS, tvOS, visionOS).
  ///
  /// Delegates window lifecycle to `AWTWindowHost`.
  @MainActor
  public final class SwiftUIToolkit: Toolkit {

    public static let shared = SwiftUIToolkit()

    private override init() {}

    public override func show(_ frame: java.awt.Frame) {
      AWTWindowHost.shared.show(frame)
    }

    public override func hide(_ frame: java.awt.Frame) {
      AWTWindowHost.shared.hide(frame)
    }
  }
}

#endif
