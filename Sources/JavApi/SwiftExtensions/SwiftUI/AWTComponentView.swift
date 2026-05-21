/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI-View, das einen AWT-Component rendert
struct AWTComponentView: View {
  let component: java.awt.Component
  
  var body: some View {
    Canvas { context, size in
      // CGContext aus SwiftUI-Canvas extrahieren und AWT-Graphics bauen
      let _ /* cgCtx */ = context  // (vereinfacht — braucht CGContext-Zugang)
                           // component.paint(Java.awt.Graphics(cgCtx))
    }
    .frame(
      width:  CGFloat(component.bounds.width),
      height: CGFloat(component.bounds.height))
  }
}
#endif
