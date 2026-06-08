/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// A cursor type — mirrors `java.awt.Cursor` from Java 1.1.
  ///
  /// In Java 1.0, cursor constants were defined directly on `Frame`.
  /// Java 1.1 introduced this class to encapsulate cursor behaviour.
  /// The integer constants match those on `Frame` for backwards compatibility.
  ///
  /// - Since: JavaApi > 0.19.1 (Java 1.1)
  public class Cursor {

    // MARK: - Cursor type constants (Java 1.1)
    public static let DEFAULT_CURSOR    = 0
    public static let CROSSHAIR_CURSOR  = 1
    public static let TEXT_CURSOR       = 2
    public static let WAIT_CURSOR       = 3
    public static let SW_RESIZE_CURSOR  = 4
    public static let SE_RESIZE_CURSOR  = 5
    public static let NW_RESIZE_CURSOR  = 6
    public static let NE_RESIZE_CURSOR  = 7
    public static let N_RESIZE_CURSOR   = 8
    public static let S_RESIZE_CURSOR   = 9
    public static let W_RESIZE_CURSOR   = 10
    public static let E_RESIZE_CURSOR   = 11
    public static let HAND_CURSOR       = 12
    public static let MOVE_CURSOR       = 13

    /// The integer type of this cursor, matching one of the constants above.
    public let type: Int

    /// Creates a cursor with the given type.
    ///
    /// - Parameter type: one of the cursor type constants on this class.
    public init(_ type: Int) {
      self.type = type
    }

    /// Returns the predefined cursor for the given type.
    ///
    /// - Parameter type: one of the cursor type constants.
    /// - Returns: a `Cursor` instance for that type.
    public static func getPredefinedCursor(_ type: Int) -> Cursor {
      return Cursor(type)
    }

    /// Returns the default cursor.
    public static func getDefaultCursor() -> Cursor {
      return Cursor(DEFAULT_CURSOR)
    }

    /// Returns the name of this cursor.
    public func getName() -> String {
      switch type {
      case Cursor.DEFAULT_CURSOR:    return "Default Cursor"
      case Cursor.CROSSHAIR_CURSOR:  return "Crosshair Cursor"
      case Cursor.TEXT_CURSOR:       return "Text Cursor"
      case Cursor.WAIT_CURSOR:       return "Wait Cursor"
      case Cursor.SW_RESIZE_CURSOR:  return "Southwest Resize Cursor"
      case Cursor.SE_RESIZE_CURSOR:  return "Southeast Resize Cursor"
      case Cursor.NW_RESIZE_CURSOR:  return "Northwest Resize Cursor"
      case Cursor.NE_RESIZE_CURSOR:  return "Northeast Resize Cursor"
      case Cursor.N_RESIZE_CURSOR:   return "North Resize Cursor"
      case Cursor.S_RESIZE_CURSOR:   return "South Resize Cursor"
      case Cursor.W_RESIZE_CURSOR:   return "West Resize Cursor"
      case Cursor.E_RESIZE_CURSOR:   return "East Resize Cursor"
      case Cursor.HAND_CURSOR:       return "Hand Cursor"
      case Cursor.MOVE_CURSOR:       return "Move Cursor"
      default:                       return "Custom Cursor"
      }
    }
  }
}
