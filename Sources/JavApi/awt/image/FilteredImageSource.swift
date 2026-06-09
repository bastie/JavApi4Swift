/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// An `ImageProducer` that wraps an existing producer and an `ImageFilter`
  /// to produce a filtered version of the original image.
  ///
  /// Each `ImageConsumer` that registers with this source gets its own
  /// filter instance (via `ImageFilter.getFilterInstance`), so multiple
  /// consumers can be served concurrently without shared filter state.
  ///
  /// ### Usage
  /// ```swift
  /// let filter = MyRGBFilter()
  /// let src    = java.awt.image.FilteredImageSource(original.getSource(), filter)
  /// // pass src to createImage(_:) or register a consumer directly
  /// ```
  public class FilteredImageSource: ImageProducer {

    // -------------------------------------------------------------------------
    // MARK: Private state
    // -------------------------------------------------------------------------

    private let producer: any ImageProducer
    private let filter:   ImageFilter

    /// Maps each registered consumer → its dedicated filter instance.
    /// The filter instance acts as the actual ImageConsumer passed to the
    /// upstream producer.
    private var filterMap: [ObjectIdentifier: ImageFilter] = [:]

    // -------------------------------------------------------------------------
    // MARK: Constructor  §2.4.1
    // -------------------------------------------------------------------------

    /// Creates a filtered image source from an existing producer and a filter.
    ///
    /// - Parameters:
    ///   - orig: The upstream image producer.
    ///   - imgf: The filter to apply.
    public init(_ orig: any ImageProducer, _ imgf: ImageFilter) {
      self.producer = orig
      self.filter   = imgf
    }

    // -------------------------------------------------------------------------
    // MARK: ImageProducer  §2.4.2 – §2.4.6
    // -------------------------------------------------------------------------

    /// Registers `ic` and creates a dedicated filter instance for it.
    /// The filter instance is added to the upstream producer.
    public func addConsumer(_ consumer: any ImageConsumer) {
      let fi = filter.getFilterInstance(consumer)
      filterMap[ObjectIdentifier(consumer)] = fi
      producer.addConsumer(fi)
    }

    /// Returns `true` if `ic` is currently registered with this source.
    public func isConsumer(_ consumer: any ImageConsumer) -> Bool {
      guard let fi = filterMap[ObjectIdentifier(consumer)] else { return false }
      return producer.isConsumer(fi)
    }

    /// Unregisters `ic` and removes its filter instance from the upstream producer.
    public func removeConsumer(_ consumer: any ImageConsumer) {
      guard let fi = filterMap.removeValue(forKey: ObjectIdentifier(consumer)) else { return }
      producer.removeConsumer(fi)
    }

    /// Registers `ic` and immediately starts producing pixels for it.
    public func startProduction(_ consumer: any ImageConsumer) {
      let fi = filter.getFilterInstance(consumer)
      filterMap[ObjectIdentifier(consumer)] = fi
      producer.startProduction(fi)
    }

    /// Forwards a top-down-left-right resend request through the filter instance.
    public func requestTopDownLeftRightResend(_ consumer: any ImageConsumer) {
      guard let fi = filterMap[ObjectIdentifier(consumer)] else { return }
      producer.requestTopDownLeftRightResend(fi)
    }
  }
}
