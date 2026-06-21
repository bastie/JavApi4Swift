/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// Base class for all descriptor types in the JavaBeans introspection API.
  ///
  /// Carries the name, display name, short description, and flag attributes
  /// (`expert`, `hidden`, `preferred`) that all feature descriptors share.
  /// Does **not** carry any `java.lang.reflect` data — those subclasses
  /// (`PropertyDescriptor`, `MethodDescriptor`, …) are not ported because Swift
  /// has no equivalent runtime method/constructor introspection API.
  ///
  /// - Since: Java 1.1
  open class FeatureDescriptor: @unchecked Sendable {

    private var _name: String = ""
    private var _displayName: String = ""
    private var _shortDescription: String = ""
    private var _expert: Bool = false
    private var _hidden: Bool = false
    private var _preferred: Bool = false

    public init() {}

    // MARK: - Name

    /// The programmatic name of this feature (camelCase, no spaces).
    open func getName() -> String { _name }

    open func setName(_ name: String) { _name = name }

    // MARK: - Display name

    /// A localised display name for this feature. Defaults to `getName()`.
    open func getDisplayName() -> String {
      _displayName.isEmpty ? _name : _displayName
    }

    open func setDisplayName(_ displayName: String) { _displayName = displayName }

    // MARK: - Short description

    /// A short description of this feature. Defaults to `getDisplayName()`.
    open func getShortDescription() -> String {
      _shortDescription.isEmpty ? getDisplayName() : _shortDescription
    }

    open func setShortDescription(_ text: String) { _shortDescription = text }

    // MARK: - Flags

    /// `true` if this feature is intended for expert users only.
    open func isExpert() -> Bool { _expert }
    open func setExpert(_ expert: Bool) { _expert = expert }

    /// `true` if this feature should be hidden from human editors.
    open func isHidden() -> Bool { _hidden }
    open func setHidden(_ hidden: Bool) { _hidden = hidden }

    /// `true` if this feature is especially important (Java 1.2 addition,
    /// included here for API completeness).
    open func isPreferred() -> Bool { _preferred }
    open func setPreferred(_ preferred: Bool) { _preferred = preferred }
  }
}
