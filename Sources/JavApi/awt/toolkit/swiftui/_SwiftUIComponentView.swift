/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI-View, das einen AWT-Component rendert.
///
/// ## Architekturhinweis — zwei Rendering-Ansätze
///
/// ### Ansatz A: Selbst zeichnen (aktuell aktiv)
/// `_SwiftUINativeCanvas` ruft `component.paint(Graphics2D)` auf und zeichnet
/// jede Komponente selbst in einen `CGContext`. Das entspricht dem
/// **Swing/lightweight**-Modell: plattformübergreifend konsistentes Aussehen,
/// volle Kontrolle, kein nativer Peer nötig.
///
/// ### Ansatz B: Native SwiftUI-Elemente pro Komponente (dieser View)
/// Das ursprüngliche **AWT heavyweight**-Modell: jede `Component` wird auf
/// ein echtes natives Widget gemappt (`Button` → SwiftUI `Button`,
/// `TextField` → SwiftUI `TextField`, usw.). Das Toolkit erzeugt dann
/// pro Komponente einen "Peer" — in Swift eine SwiftUI-View statt eines
/// nativen `ComponentPeer`.
///
/// Vorteile von Ansatz B: natives Look & Feel, Accessibility, Keyboard-
/// und Fokus-Handling gratis vom System.
/// Nachteil: jede AWT-Komponente braucht ein explizites SwiftUI-Mapping;
/// `paint(Graphics)` wird nicht mehr aufgerufen.
///
/// Dieser View ist ein unvollständiger Prototyp für Ansatz B. Der
/// `CGContext`-Zugriff aus SwiftUI `Canvas` ist nicht trivial (SwiftUI
/// kapselt ihn), weshalb die Implementierung zunächst zugunsten von
/// `_SwiftUINativeCanvas` (Ansatz A) zurückgestellt wurde.
///
/// - TODO: Ansatz B ausimplementieren wenn natives Look & Feel gewünscht wird.
///   Einstiegspunkt: `GraphicsContext` in SwiftUI 4+ via `withCGContext` oder
///   pro Komponententyp eine dedizierte SwiftUI-View statt eines generischen Canvas.
struct _SwiftUIComponentView: View {
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
