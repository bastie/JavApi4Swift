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
      // Plattformspezifische Modalität wird in _SwiftUIWindowHost behandelt.
      // Hier nur AWT-seitiger State + Toolkit-Dispatch.
      super.setVisible(visible)
    }

    // -------------------------------------------------------------------------
    // MARK: WindowEvent-Verarbeitung
    // -------------------------------------------------------------------------

    /// Fires registered `WindowListener` callbacks **and** disposes the dialog
    /// automatically when the platform close button (X) is clicked.
    ///
    /// Java AWT's default close operation for `Dialog` is equivalent to
    /// `DISPOSE_ON_CLOSE`: clicking the X button calls `dispose()`.  Subclasses
    /// that want different behaviour should override this method.
    open override func processWindowEvent(_ e: java.awt.event.WindowEvent) {
      super.processWindowEvent(e)   // notify registered WindowListeners first
      if e.getID() == java.awt.event.WindowEvent.WINDOW_CLOSING {
        dispose()
      }
    }

    /// Schließt den Dialog und beendet ggf. den modalen Loop.
    open override func dispose() {
      java.awt.Toolkit.getDefaultToolkit().closeDialog(self)
    }
  }
}
