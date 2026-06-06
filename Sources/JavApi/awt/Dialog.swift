/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Modales oder nicht-modales Dialogfenster — mirrors `java.awt.Dialog`.
  ///
  /// Hierarchie: Component → Container → Window → **Dialog** → FileDialog
  ///
  /// Im Gegensatz zu `Frame` hat `Dialog` immer einen Besitzer (`owner`)
  /// und kann modal sein, d.h. er blockiert Eingaben an das Besitzerfenster.
  @MainActor
  open class Dialog: Window {

    // -------------------------------------------------------------------------
    // MARK: Modalitäts-Konstanten (Java 1.6+, hier als typsicheres Enum)
    // -------------------------------------------------------------------------

    public enum ModalityType: Int {
      /// Nicht-modal — kein Fenster wird blockiert.
      case modeless          = 0
      /// Blockiert das Besitzerfenster und dessen Kinder.
      case applicationModal  = 1
      /// Blockiert alle Fenster der Anwendung.
      case documentModal     = 2
      /// Blockiert alle Fenster aller Anwendungen (selten verwendet).
      case toolkitModal      = 3
    }

    // -------------------------------------------------------------------------
    // MARK: Eigenschaften
    // -------------------------------------------------------------------------

    public private(set) var title: String
    public private(set) var modal: Bool
    public private(set) var modalityType: ModalityType
    public weak var owner: Window?

    /// Ob das Dialogfenster in der Größe verändert werden kann.
    public var resizable: Bool = true

    // -------------------------------------------------------------------------
    // MARK: Konstruktoren
    // -------------------------------------------------------------------------

    /// Erstellt einen modalen oder nicht-modalen Dialog mit Besitzerfenster.
    public init(_ owner: Frame?, _ title: String = "", _ modal: Bool = false) {
      self.owner        = owner
      self.title        = title
      self.modal        = modal
      self.modalityType = modal ? .applicationModal : .modeless
    }

    /// Erstellt einen Dialog mit explizitem `ModalityType`.
    public init(_ owner: Frame?, _ title: String = "",
                modalityType: ModalityType) {
      self.owner        = owner
      self.title        = title
      self.modal        = modalityType != .modeless
      self.modalityType = modalityType
    }

    /// Erstellt einen Dialog mit Window-Besitzer.
    public init(_ owner: Window?, _ title: String = "", _ modal: Bool = false) {
      self.owner        = owner
      self.title        = title
      self.modal        = modal
      self.modalityType = modal ? .applicationModal : .modeless
    }

    // -------------------------------------------------------------------------
    // MARK: Titel
    // -------------------------------------------------------------------------

    public func getTitle() -> String  { title }
    public func setTitle(_ t: String) { title = t }

    // -------------------------------------------------------------------------
    // MARK: Modalität
    // -------------------------------------------------------------------------

    public func isModal() -> Bool            { modal }
    public func getModalityType() -> ModalityType { modalityType }

    public func setModal(_ modal: Bool) {
      self.modal        = modal
      self.modalityType = modal ? .applicationModal : .modeless
    }

    public func setModalityType(_ type: ModalityType) {
      self.modalityType = type
      self.modal        = type != .modeless
    }

    // -------------------------------------------------------------------------
    // MARK: Sichtbarkeit — überschreibt Window.setVisible für Modalität
    // -------------------------------------------------------------------------

    open override func setVisible(_ visible: Bool) {
      // Plattformspezifische Modalität wird in AWTWindowHost behandelt.
      // Hier nur AWT-seitiger State + Toolkit-Dispatch.
      super.setVisible(visible)
    }

    /// Schließt den Dialog und beendet ggf. den modalen Loop.
    open override func dispose() {
#if os(macOS) && canImport(SwiftUI)
      AWTWindowHost.shared.closeDialog(self)
#else
      super.dispose()
#endif
    }
  }
}
