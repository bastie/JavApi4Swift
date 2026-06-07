/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI


// ---------------------------------------------------------------------------
// MARK: ViewRepresentable-Brücke (macOS / iOS)
// ---------------------------------------------------------------------------

#if os(macOS)
import AppKit

internal struct _AWTCanvasViewRepresentable: NSViewRepresentable {
  
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

#elseif os(iOS) || os(tvOS)
import UIKit

internal struct _AWTCanvasViewRepresentable: UIViewRepresentable {
  
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
#else
// ---------------------------------------------------------------------------
// MARK: Linux / headless stub
// ---------------------------------------------------------------------------

private struct _AWTCanvasViewRepresentable: View {
  let component: java.awt.Component
  var body: some View { EmptyView() }
}

#endif
#endif
