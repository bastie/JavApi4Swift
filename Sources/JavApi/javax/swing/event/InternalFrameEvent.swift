/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// An event that indicates a `JInternalFrame` has changed its status.
  ///
  /// `InternalFrameEvent` is fired by `JInternalFrame` to notify
  /// `InternalFrameListener`s when an internal frame is opened, closed,
  /// iconified, deiconified, activated, or deactivated.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class InternalFrameEvent: java.awt.AWTEvent, @unchecked Sendable {

    // MARK: - Event IDs

    /// Marks the first integer id for the range of internal frame event ids.
    public static let INTERNAL_FRAME_FIRST: Int = 25549

    /// Marks the last integer id for the range of internal frame event ids.
    public static let INTERNAL_FRAME_LAST: Int = 25555

    /// The internal frame was opened.
    public static let INTERNAL_FRAME_OPENED: Int = INTERNAL_FRAME_FIRST

    /// The internal frame is closing.
    public static let INTERNAL_FRAME_CLOSING: Int = 25550

    /// The internal frame was closed.
    public static let INTERNAL_FRAME_CLOSED: Int = 25551

    /// The internal frame was iconified.
    public static let INTERNAL_FRAME_ICONIFIED: Int = 25552

    /// The internal frame was deiconified.
    public static let INTERNAL_FRAME_DEICONIFIED: Int = 25553

    /// The internal frame was activated.
    public static let INTERNAL_FRAME_ACTIVATED: Int = 25554

    /// The internal frame was deactivated.
    public static let INTERNAL_FRAME_DEACTIVATED: Int = INTERNAL_FRAME_LAST

    // MARK: - Init

    /// Creates an `InternalFrameEvent` with the given source frame and id.
    ///
    /// - Parameters:
    ///   - source: The `JInternalFrame` that originated the event.
    ///   - id:     One of the `INTERNAL_FRAME_*` constants.
    public override init(_ source: AnyObject, _ id: Int) {
      super.init(source, id)
    }

    // MARK: - Accessors

    /// Returns a parameter string identifying this event.
    public func paramString() -> String {
      let typeStr: String
      switch id {
      case InternalFrameEvent.INTERNAL_FRAME_OPENED:      typeStr = "INTERNAL_FRAME_OPENED"
      case InternalFrameEvent.INTERNAL_FRAME_CLOSING:     typeStr = "INTERNAL_FRAME_CLOSING"
      case InternalFrameEvent.INTERNAL_FRAME_CLOSED:      typeStr = "INTERNAL_FRAME_CLOSED"
      case InternalFrameEvent.INTERNAL_FRAME_ICONIFIED:   typeStr = "INTERNAL_FRAME_ICONIFIED"
      case InternalFrameEvent.INTERNAL_FRAME_DEICONIFIED: typeStr = "INTERNAL_FRAME_DEICONIFIED"
      case InternalFrameEvent.INTERNAL_FRAME_ACTIVATED:   typeStr = "INTERNAL_FRAME_ACTIVATED"
      case InternalFrameEvent.INTERNAL_FRAME_DEACTIVATED: typeStr = "INTERNAL_FRAME_DEACTIVATED"
      default:                                             typeStr = "unknown type"
      }
      return typeStr
    }
  }
}
