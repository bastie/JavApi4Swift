/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing {

  /// An `Icon` backed by a `java.awt.Image`.
  ///
  /// Load via the AWT Toolkit, exactly like `LogoCanvas` does:
  ///
  /// ```swift
  /// let toolkit = java.awt.Toolkit.getDefaultToolkit()
  /// if let img = toolkit.loadImage(named: "MyIcon") {
  ///   let icon = javax.swing.ImageIcon(img)
  ///   button.setIcon(icon)
  /// }
  /// ```
  ///
  /// - Since: Java 1.2
  @MainActor
  public final class ImageIcon: javax.swing.Icon {

    private let image: java.awt.Image
    private let width: Int
    private let height: Int

    /// Creates an `ImageIcon` from a pre-loaded `java.awt.Image`.
    /// `width` and `height` default to the image's own dimensions when ≤ 0.
    public init(_ image: java.awt.Image, width: Int = 0, height: Int = 0) {
      self.image  = image
      self.width  = width  > 0 ? width  : image.getWidth()
      self.height = height > 0 ? height : image.getHeight()
    }

    /// Convenience: load by asset name via `Toolkit.loadImage(named:)`.
    /// Returns `nil` when the image cannot be found.
    public static func load(named name: String,
                            width: Int = 0,
                            height: Int = 0) -> javax.swing.ImageIcon? {
      let toolkit = java.awt.Toolkit.getDefaultToolkit()
      guard let img = toolkit.loadImage(named: name) else { return nil }
      return ImageIcon(img, width: width, height: height)
    }

    // -------------------------------------------------------------------------
    // MARK: Icon
    // -------------------------------------------------------------------------

    public func getIconWidth()  -> Int { width }
    public func getIconHeight() -> Int { height }

    public func paintIcon(_ c: java.awt.Component?,
                          _ g: java.awt.Graphics,
                          _ x: Int, _ y: Int) {
      g.drawImage(image, x, y, width, height)
    }

    // -------------------------------------------------------------------------
    // MARK: Raw image access
    // -------------------------------------------------------------------------

    public func getImage() -> java.awt.Image { image }
  }
}
