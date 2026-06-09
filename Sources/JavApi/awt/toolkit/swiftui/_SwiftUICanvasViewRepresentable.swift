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

internal struct _SwiftUICanvasViewRepresentable: NSViewRepresentable {
  
  let component: java.awt.Component
  
  func makeNSView(context: Context) -> _SwiftUINativeCanvas {
    let v = _SwiftUINativeCanvas()
    v.component = component
    return v
  }
  
  func updateNSView(_ nsView: _SwiftUINativeCanvas, context: Context) {
    nsView.component = component
    nsView.needsDisplay = true
  }
}

#elseif os(iOS) || os(tvOS)
import UIKit

internal struct _SwiftUICanvasViewRepresentable: UIViewRepresentable {

  let component: java.awt.Component

  func makeUIView(context: Context) -> _SwiftUINativeCanvas {
    let v = _SwiftUINativeCanvas()
    v.component = component
    return v
  }

  func updateUIView(_ uiView: _SwiftUINativeCanvas, context: Context) {
    uiView.component = component
    uiView.setNeedsDisplay()
  }
}
#else
// ---------------------------------------------------------------------------
// MARK: Linux / headless stub
// ---------------------------------------------------------------------------

internal struct _SwiftUICanvasViewRepresentable: View {
  let component: java.awt.Component
  var body: some View { EmptyView() }
}

#endif
#endif
