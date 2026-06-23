/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.awt {

  /// Nativer Dateiauswahl-Dialog — mirrors `java.awt.FileDialog`.
  ///
  /// Hierarchie: Component → Container → Window → Dialog → **FileDialog**
  ///
  /// Auf macOS mappt `LOAD` auf `NSOpenPanel` und `SAVE` auf `NSSavePanel`.
  /// Der Dialog ist immer modal (Java-Spezifikation).
  ///
  /// ### Verwendung
  /// ```swift
  /// let fd = java.awt.FileDialog(parentFrame, "Öffnen", java.awt.FileDialog.LOAD)
  /// fd.setVisible(true)          // blockiert bis der User auswählt oder abbricht
  /// if let file = fd.getFile() {
  ///   print(fd.getDirectory()! + file)
  /// }
  /// ```
  @MainActor
  open class FileDialog: Dialog, @MainActor java.awt.toolkit.FileDialogProvider {

    // -------------------------------------------------------------------------
    // MARK: Modus-Konstanten
    // -------------------------------------------------------------------------

    /// open mode
    public static let LOAD = FileDialogMode.LOAD.rawValue
    /// save mode
    public static let SAVE = FileDialogMode.SAVE.rawValue

    // -------------------------------------------------------------------------
    // MARK: Eigenschaften
    // -------------------------------------------------------------------------

    /// the mode `LOAD` or `SAVE`.
    internal var mode: FileDialogMode

    /// Verzeichnis, das beim Öffnen angezeigt wird.
    /// Nach `setVisible(true)` enthält es das Verzeichnis der gewählten Datei.
    internal var directory: String?

    /// Dateiname ohne Verzeichnispfad.
    /// Nach `setVisible(true)` enthält es den gewählten Namen, oder `nil`
    /// wenn der Nutzer abgebrochen hat.
    internal var file: String?

    /// Optionaler Dateifilter, z.B. `"*.swift;*.txt"` oder `"swift;txt"`.
    internal var filenameFilter: String?

    // -------------------------------------------------------------------------
    // MARK: Konstruktoren
    // -------------------------------------------------------------------------

    public init(_ parent: Frame?, _ title: String = "", _ mode: Int = FileDialog.LOAD) throws (IllegalArgumentException) {
      guard nil != FileDialogMode(rawValue: mode) else {
        throw IllegalArgumentException("illegal file dialog mode: \(mode)")
      }
      self.mode = FileDialogMode(rawValue: mode)! // thx guard, ! is save
      super.init(parent, title, true)   // FileDialog ist laut Java-Spec immer modal
    }

    // -------------------------------------------------------------------------
    // MARK: Java API
    // -------------------------------------------------------------------------

    public func getMode()      -> Int     {
      mode.rawValue
    }
    public func getDirectory() -> String? {
      directory
    }
    public func getFile()      -> String? {
      file
    }

    public func setDirectory(_ dir: String?) {
      directory = dir
    }
    public func setFile(_ f: String?)        {
      file = f
    }
    
    /// Set the mode of FileDialog
    /// - Parameter mode: mode `SAVE` or `LOAD`
    public func setMode(_ mode: Int) throws {
      guard nil != FileDialogMode(rawValue: mode) else {
        throw IllegalArgumentException("illegal file dialog mode: \(mode)")
      }
      self.mode = FileDialogMode(rawValue: mode)! // thx guard, ! is save
    }

    /// Delegates working to platform native implementiation
    /// - SeeAlso: FileDialogProvider for native implementation
    open override func setVisible(_ visible: Bool) {
      guard visible else { return }
      _setToolkitVisible()
    }

    // -------------------------------------------------------------------------
    // MARK: Hilfsmethoden (plattformunabhängig)
    // -------------------------------------------------------------------------

    /// parsing `"*.swift;*.txt"` or `"swift;txt"` to `["swift", "txt"]`.
    internal func parseExtensions(_ filter: String?) -> [String] {
      guard let f = filter, !f.isEmpty else { return [] }
      return f
        .components(separatedBy: CharacterSet(charactersIn: ";,| "))
        .map { $0.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "*.", with: "")
            .replacingOccurrences(of: ".",  with: "")
        }
        .filter { !$0.isEmpty }
    }

  }
}
