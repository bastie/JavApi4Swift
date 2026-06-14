/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension javax.swing.event {

  /// Enumerates the three kinds of document change.
  ///
  /// Swift does not allow types to be defined inside a protocol or a protocol
  /// extension, so `EventType` lives at the `javax.swing.event` level.
  /// The `DocumentEvent` protocol exposes it via `typealias EventType` so
  /// call-sites can write `DocumentEvent.EventType` — identical to the Java API.
  public enum DocumentEventType: Hashable, Equatable {
    case INSERT
    case REMOVE
    case CHANGE
  }

  /// Describes a change in a `Document`.
  ///
  /// `DocumentEvent` is passed to `DocumentListener` methods to describe
  /// what changed in the document's content.
  ///
  /// Three change types are possible:
  ///
  /// | `EventType`  | Meaning                        |
  /// |--------------|--------------------------------|
  /// | `INSERT`     | Text was inserted              |
  /// | `REMOVE`     | Text was removed               |
  /// | `CHANGE`     | Attributes changed (no content change) |
  ///
  /// - Since: Java 1.2
  @MainActor
  public protocol DocumentEvent: AnyObject {

    /// Mirrors Java's nested `DocumentEvent.EventType`.
    typealias EventType = javax.swing.event.DocumentEventType

    /// The type of document change.
    var type: EventType { get }

    /// The offset within the document where the change began.
    var offset: Int { get }

    /// The length of the changed region.
    var length: Int { get }

    /// The `Document` that fired this event.
    var document: javax.swing.text.Document { get }
  }
}
