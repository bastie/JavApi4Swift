/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Event fired by a `JEditorPane` when the user interacts with a hyperlink.
  ///
  /// The event carries the type of interaction (`ENTERED`, `EXITED`,
  /// `ACTIVATED`), the target URL as a `String`, and a descriptive text.
  ///
  /// - Since: Java 1.2
  @MainActor
  public class HyperlinkEvent: java.util.EventObject, @unchecked Sendable {

    // -------------------------------------------------------------------------
    // MARK: EventType
    // -------------------------------------------------------------------------

    /// Describes the kind of hyperlink interaction.
    public enum EventType: Sendable {
      /// The mouse entered the hyperlink area.
      case ENTERED
      /// The mouse left the hyperlink area.
      case EXITED
      /// The user activated (clicked) the hyperlink.
      case ACTIVATED
    }

    // -------------------------------------------------------------------------
    // MARK: Properties
    // -------------------------------------------------------------------------

    private let eventType:   EventType
    private let url:         String?
    private let description: String?

    // -------------------------------------------------------------------------
    // MARK: Initializers
    // -------------------------------------------------------------------------

    /// Creates a `HyperlinkEvent`.
    ///
    /// - Parameters:
    ///   - source:      The `JEditorPane` that fired the event.
    ///   - type:        The event type.
    ///   - url:         The target URL string, or `nil`.
    ///   - description: Descriptive text (typically the link text).
    public init(_ source: AnyObject,
                _ type: EventType,
                _ url: String? = nil,
                _ description: String? = nil) {
      self.eventType   = type
      self.url         = url
      self.description = description
      super.init(source)
    }

    // -------------------------------------------------------------------------
    // MARK: Accessors
    // -------------------------------------------------------------------------

    public func getEventType()   -> EventType { eventType }
    public func getURL()         -> String?   { url }
    public func getDescription() -> String?   { description }
  }
}
