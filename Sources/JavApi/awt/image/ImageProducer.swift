/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.image {

  /// Source of pixel data for an image — mirrors `java.awt.image.ImageProducer`.
  ///
  /// A producer delivers pixel data to one or more `ImageConsumer` instances.
  /// The typical sequence is:
  /// 1. A consumer registers via `addConsumer`.
  /// 2. The producer calls `startProduction` to begin delivery.
  /// 3. Pixel data flows through the `ImageConsumer` callbacks.
  /// 4. The producer calls `imageComplete` on each consumer when done.
  public protocol ImageProducer: AnyObject {

    /// Register `consumer` to receive pixel data from this producer.
    func addConsumer(_ consumer: any java.awt.image.ImageConsumer)

    /// Returns `true` if `consumer` is currently registered.
    func isConsumer(_ consumer: any java.awt.image.ImageConsumer) -> Bool

    /// Unregister `consumer`; no further callbacks will be made to it.
    func removeConsumer(_ consumer: any java.awt.image.ImageConsumer)

    /// Start (or restart) pixel delivery to `consumer`.
    /// If `consumer` is not yet registered it should be added first.
    func startProduction(_ consumer: any java.awt.image.ImageConsumer)

    /// Request that pixels be re-delivered top-down, left-to-right to `consumer`.
    /// Producers that cannot honour this request may ignore it.
    func requestTopDownLeftRightResend(_ consumer: any java.awt.image.ImageConsumer)
  }
}
