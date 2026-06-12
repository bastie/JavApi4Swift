/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.peer {

  /// Native peer interface for `java.awt.Component`.
  ///
  /// If in JavApi⁴Swift the AWT components render themselves directly; there is no
  /// separate native widget.  The peer protocol is implemented by the AWT
  /// component classes themselves so that code expecting a peer object receives
  /// the component as its own peer.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.0)
  @MainActor
  public protocol ComponentPeer: AnyObject {

    /// Makes the component visible.
    func show()
    /// Hides the component.
    func hide()
    /// Enables the component so it can receive input.
    func enable()
    /// Disables the component.
    func disable()

    /// Paints the component using the given graphics context.
    func paint(_ g: java.awt.Graphics)
    /// Prints the component using the given graphics context.
    func print(_ g: java.awt.Graphics)
    /// Repaints the component after `tm` milliseconds, clipped to the given rectangle.
    func repaint(_ tm: Int, _ x: Int, _ y: Int, _ width: Int, _ height: Int)

    /// Moves and resizes the component.
    func reshape(_ x: Int, _ y: Int, _ width: Int, _ height: Int)

    /// Dispatches the given event to the component.
    /// Uses ``java.awt.Event`` intentionally — this is the Java 1.0 peer API.
    @available(*, deprecated, message: "Java 1.0 peer API — use java.awt.event listeners for new code")
    func handleEvent(_ e: java.awt.Event) -> Bool

    /// Returns the minimum size of the component.
    func minimumSize() -> java.awt.Dimension
    /// Returns the preferred size of the component.
    func preferredSize() -> java.awt.Dimension

    /// Returns the color model used by this component.
    func getColorModel() -> java.awt.image.ColorModel
    /// Returns a graphics context for this component.
    func getGraphics() -> java.awt.Graphics
    /// Returns the font metrics for the given font.
    func getFontMetrics(_ f: java.awt.Font) -> java.awt.FontMetrics

    /// Disposes of this peer and releases its resources.
    func dispose()

    /// Sets the foreground color.
    func setForegroundColor(_ c: java.awt.Color)
    /// Sets the background color.
    func setBackgroundColor(_ c: java.awt.Color)
    /// Sets the font.
    func setFont(_ f: java.awt.Font)

    /// Requests keyboard focus for this component.
    func requestFocus()
    /// Transfers focus to the next component.
    func nextFocus()

    /// Creates an image from the given producer.
    func createImage(_ producer: any java.awt.image.ImageProducer) -> java.awt.Image
    /// Creates an off-screen image of the given size.
    func createImage(_ width: Int, _ height: Int) -> java.awt.Image
    /// Prepares an image for rendering.
    func prepareImage(_ image: java.awt.Image, _ width: Int, _ height: Int,
                      _ observer: any java.awt.ImageObserver) -> Bool
    /// Checks the status of image construction.
    func checkImage(_ image: java.awt.Image, _ width: Int, _ height: Int,
                    _ observer: any java.awt.ImageObserver) -> Int
  }
}
