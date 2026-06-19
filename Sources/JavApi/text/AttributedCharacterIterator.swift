/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.text {

  // ---------------------------------------------------------------------------
  // MARK: Attribute key class (nested type of AttributedCharacterIterator)
  // ---------------------------------------------------------------------------
  // Swift does not allow class definitions inside protocol extensions, so
  // `Attribute` lives directly in the `java.text` namespace and is re-exported
  // via a typealias on the protocol below.
  //
  // Java usage:    AttributedCharacterIterator.Attribute.LANGUAGE
  // Swift usage:   java.text.AttributedCharacterIterator.Attribute.LANGUAGE
  //                (typealias resolves to java.text.AttributedCharacterIteratorAttribute)

  /// Defines attribute key constants used in attributed strings.
  ///
  /// Mirrors `java.text.AttributedCharacterIterator.Attribute`.
  ///
  /// - Since: Java 1.2
  open class AttributedCharacterIteratorAttribute : Hashable, CustomStringConvertible, @unchecked Sendable {

    private let name: String

    /// Creates an `Attribute` with the given name.
    public init(_ name: String) {
      self.name = name
    }

    /// The name of this attribute.
    public var attributeName: String { name }

    // -------------------------------------------------------------------------
    // MARK: Predefined keys
    // -------------------------------------------------------------------------

    /// Attribute key for the language of some text.
    public static let LANGUAGE  = AttributedCharacterIteratorAttribute("language")

    /// Attribute key for the reading (phonetic annotation) of some text.
    public static let READING   = AttributedCharacterIteratorAttribute("reading")

    /// Attribute key for an input method segment.
    public static let INPUT_METHOD_SEGMENT = AttributedCharacterIteratorAttribute("input_method_segment")

    // -------------------------------------------------------------------------
    // MARK: Hashable / CustomStringConvertible
    // -------------------------------------------------------------------------

    public static func == (lhs: AttributedCharacterIteratorAttribute,
                           rhs: AttributedCharacterIteratorAttribute) -> Bool {
      return lhs === rhs || lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }

    public var description: String { name }
  }

  // ---------------------------------------------------------------------------
  // MARK: Protocol
  // ---------------------------------------------------------------------------

  /// Extends ``CharacterIterator`` with attributed text support.
  ///
  /// Mirrors `java.text.AttributedCharacterIterator`.
  ///
  /// An `AttributedCharacterIterator` allows the client both to iterate through
  /// a string and to retrieve information about the attributes associated with
  /// the characters in that string.
  ///
  /// - Since: Java 1.2 (included here because `MessageFormat.formatToCharacterIterator`
  ///   depends on it and it is the natural companion to `CharacterIterator`)
  public protocol AttributedCharacterIterator : CharacterIterator {

    /// Type alias matching the Java nested-class name.
    typealias Attribute = java.text.AttributedCharacterIteratorAttribute

    /// Returns the index of the first character of the run with respect to
    /// all attributes containing the current character.
    func getRunStart() -> Int

    /// Returns the index of the first character following the run with respect
    /// to all attributes containing the current character.
    func getRunLimit() -> Int

    /// Returns a map with the attributes defined on the current character.
    func getAttributes() -> [Attribute : Any]

    /// Returns the value of the named `attribute` for the current character.
    func getAttribute(_ attribute: Attribute) -> Any?

    /// Returns the keys of all attributes defined in the iterator's text range.
    func getAllAttributeKeys() -> Set<Attribute>
  }
}
