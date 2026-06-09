/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI-View, das einen `Java.awt.Component` durch Aufruf von
/// `paint(Graphics)` zeichnet.
///
/// Die SwiftUI `Canvas` stellt einen `CGContext` bereit; daraus wird eine
/// `Java.awt.Graphics2D`-Instanz gebaut und an `component.paint` übergeben.
struct _SwiftUICanvasView: View {
  
  /// Die zu rendernde AWT-Komponente.
  let component: java.awt.Component
  
  var body: some View {
    _SwiftUICanvasViewRepresentable(component: component)
      .frame(
        width:  CGFloat(component.bounds.width),
        height: CGFloat(component.bounds.height))
  }
}

#endif
