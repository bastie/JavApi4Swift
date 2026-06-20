/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Chains AWT event listeners using a binary-tree structure.
  ///
  /// Mirrors `java.awt.AWTEventMulticaster`. The static `add` / `remove`
  /// methods are the primary API: they combine or split listener chains
  /// without callers knowing how many listeners are registered.
  ///
  /// ```swift
  /// var listener: (any java.awt.event.ActionListener)? = nil
  /// listener = java.awt.AWTEventMulticaster.add(listener, myListener)
  /// listener = java.awt.AWTEventMulticaster.remove(listener, myListener)
  /// ```
  ///
  /// - Since: JavaApi > 0.x (Java 1.1)
  @MainActor
  public final class AWTEventMulticaster:
    java.awt.event.ActionListener,
    java.awt.event.AdjustmentListener,
    java.awt.event.ComponentListener,
    java.awt.event.FocusListener,
    java.awt.event.ItemListener,
    java.awt.event.KeyListener,
    java.awt.event.MouseListener,
    java.awt.event.MouseMotionListener,
    java.awt.event.TextListener,
    java.awt.event.WindowListener
  {

    // =========================================================================
    // MARK: - Chain nodes
    // =========================================================================

    private let a: any java.util.EventListener
    private let b: any java.util.EventListener

    private init(_ a: any java.util.EventListener, _ b: any java.util.EventListener) {
      self.a = a
      self.b = b
    }

    // =========================================================================
    // MARK: - Static add / remove helpers
    // =========================================================================

    // -- ActionListener -------------------------------------------------------

    public static func add(_ a: (any java.awt.event.ActionListener)?,
                           _ b: (any java.awt.event.ActionListener)?)
      -> (any java.awt.event.ActionListener)? {
      return addListeners(a, b) as? any java.awt.event.ActionListener
    }

    public static func remove(_ l: (any java.awt.event.ActionListener)?,
                              _ oldl: any java.awt.event.ActionListener)
      -> (any java.awt.event.ActionListener)? {
      return removeListener(l, oldl) as? any java.awt.event.ActionListener
    }

    // -- AdjustmentListener ---------------------------------------------------

    public static func add(_ a: (any java.awt.event.AdjustmentListener)?,
                           _ b: (any java.awt.event.AdjustmentListener)?)
      -> (any java.awt.event.AdjustmentListener)? {
      return addListeners(a, b) as? any java.awt.event.AdjustmentListener
    }

    public static func remove(_ l: (any java.awt.event.AdjustmentListener)?,
                              _ oldl: any java.awt.event.AdjustmentListener)
      -> (any java.awt.event.AdjustmentListener)? {
      return removeListener(l, oldl) as? any java.awt.event.AdjustmentListener
    }

    // -- ComponentListener ----------------------------------------------------

    public static func add(_ a: (any java.awt.event.ComponentListener)?,
                           _ b: (any java.awt.event.ComponentListener)?)
      -> (any java.awt.event.ComponentListener)? {
      return addListeners(a, b) as? any java.awt.event.ComponentListener
    }

    public static func remove(_ l: (any java.awt.event.ComponentListener)?,
                              _ oldl: any java.awt.event.ComponentListener)
      -> (any java.awt.event.ComponentListener)? {
      return removeListener(l, oldl) as? any java.awt.event.ComponentListener
    }

    // -- FocusListener --------------------------------------------------------

    public static func add(_ a: (any java.awt.event.FocusListener)?,
                           _ b: (any java.awt.event.FocusListener)?)
      -> (any java.awt.event.FocusListener)? {
      return addListeners(a, b) as? any java.awt.event.FocusListener
    }

    public static func remove(_ l: (any java.awt.event.FocusListener)?,
                              _ oldl: any java.awt.event.FocusListener)
      -> (any java.awt.event.FocusListener)? {
      return removeListener(l, oldl) as? any java.awt.event.FocusListener
    }

    // -- ItemListener ---------------------------------------------------------

    public static func add(_ a: (any java.awt.event.ItemListener)?,
                           _ b: (any java.awt.event.ItemListener)?)
      -> (any java.awt.event.ItemListener)? {
      return addListeners(a, b) as? any java.awt.event.ItemListener
    }

    public static func remove(_ l: (any java.awt.event.ItemListener)?,
                              _ oldl: any java.awt.event.ItemListener)
      -> (any java.awt.event.ItemListener)? {
      return removeListener(l, oldl) as? any java.awt.event.ItemListener
    }

    // -- KeyListener ----------------------------------------------------------

    public static func add(_ a: (any java.awt.event.KeyListener)?,
                           _ b: (any java.awt.event.KeyListener)?)
      -> (any java.awt.event.KeyListener)? {
      return addListeners(a, b) as? any java.awt.event.KeyListener
    }

    public static func remove(_ l: (any java.awt.event.KeyListener)?,
                              _ oldl: any java.awt.event.KeyListener)
      -> (any java.awt.event.KeyListener)? {
      return removeListener(l, oldl) as? any java.awt.event.KeyListener
    }

    // -- MouseListener --------------------------------------------------------

    public static func add(_ a: (any java.awt.event.MouseListener)?,
                           _ b: (any java.awt.event.MouseListener)?)
      -> (any java.awt.event.MouseListener)? {
      return addListeners(a, b) as? any java.awt.event.MouseListener
    }

    public static func remove(_ l: (any java.awt.event.MouseListener)?,
                              _ oldl: any java.awt.event.MouseListener)
      -> (any java.awt.event.MouseListener)? {
      return removeListener(l, oldl) as? any java.awt.event.MouseListener
    }

    // -- MouseMotionListener --------------------------------------------------

    public static func add(_ a: (any java.awt.event.MouseMotionListener)?,
                           _ b: (any java.awt.event.MouseMotionListener)?)
      -> (any java.awt.event.MouseMotionListener)? {
      return addListeners(a, b) as? any java.awt.event.MouseMotionListener
    }

    public static func remove(_ l: (any java.awt.event.MouseMotionListener)?,
                              _ oldl: any java.awt.event.MouseMotionListener)
      -> (any java.awt.event.MouseMotionListener)? {
      return removeListener(l, oldl) as? any java.awt.event.MouseMotionListener
    }

    // -- TextListener ---------------------------------------------------------

    public static func add(_ a: (any java.awt.event.TextListener)?,
                           _ b: (any java.awt.event.TextListener)?)
      -> (any java.awt.event.TextListener)? {
      return addListeners(a, b) as? any java.awt.event.TextListener
    }

    public static func remove(_ l: (any java.awt.event.TextListener)?,
                              _ oldl: any java.awt.event.TextListener)
      -> (any java.awt.event.TextListener)? {
      return removeListener(l, oldl) as? any java.awt.event.TextListener
    }

    // -- WindowListener -------------------------------------------------------

    public static func add(_ a: (any java.awt.event.WindowListener)?,
                           _ b: (any java.awt.event.WindowListener)?)
      -> (any java.awt.event.WindowListener)? {
      return addListeners(a, b) as? any java.awt.event.WindowListener
    }

    public static func remove(_ l: (any java.awt.event.WindowListener)?,
                              _ oldl: any java.awt.event.WindowListener)
      -> (any java.awt.event.WindowListener)? {
      return removeListener(l, oldl) as? any java.awt.event.WindowListener
    }

    // =========================================================================
    // MARK: - Core chain logic (private)
    // =========================================================================

    private static func addListeners(
      _ a: (any java.util.EventListener)?,
      _ b: (any java.util.EventListener)?
    ) -> (any java.util.EventListener)? {
      guard let a else { return b }
      guard let b else { return a }
      return AWTEventMulticaster(a, b)
    }

    private static func removeListener(
      _ l: (any java.util.EventListener)?,
      _ oldl: any java.util.EventListener
    ) -> (any java.util.EventListener)? {
      guard let l else { return nil }
      if let mc = l as? AWTEventMulticaster {
        return mc.remove(oldl)
      }
      // l is a leaf — remove it if it is oldl
      return (l as AnyObject) === (oldl as AnyObject) ? nil : l
    }

    private func remove(_ oldl: any java.util.EventListener) -> (any java.util.EventListener)? {
      if (a as AnyObject) === (oldl as AnyObject) { return b }
      if (b as AnyObject) === (oldl as AnyObject) { return a }
      let newA = AWTEventMulticaster.removeListener(a, oldl)
      let newB = AWTEventMulticaster.removeListener(b, oldl)
      if (newA as AnyObject) === (a as AnyObject) &&
         (newB as AnyObject) === (b as AnyObject) {
        return self   // nothing changed
      }
      return AWTEventMulticaster.addListeners(newA, newB)
    }

    // =========================================================================
    // MARK: - ActionListener
    // =========================================================================

    public func actionPerformed(_ e: java.awt.event.ActionEvent) {
      (a as? java.awt.event.ActionListener)?.actionPerformed(e)
      (b as? java.awt.event.ActionListener)?.actionPerformed(e)
    }

    // =========================================================================
    // MARK: - AdjustmentListener
    // =========================================================================

    public func adjustmentValueChanged(_ e: java.awt.event.AdjustmentEvent) {
      (a as? java.awt.event.AdjustmentListener)?.adjustmentValueChanged(e)
      (b as? java.awt.event.AdjustmentListener)?.adjustmentValueChanged(e)
    }

    // =========================================================================
    // MARK: - ComponentListener
    // =========================================================================

    public func componentResized(_ e: java.awt.event.ComponentEvent) {
      (a as? java.awt.event.ComponentListener)?.componentResized(e)
      (b as? java.awt.event.ComponentListener)?.componentResized(e)
    }
    public func componentMoved(_ e: java.awt.event.ComponentEvent) {
      (a as? java.awt.event.ComponentListener)?.componentMoved(e)
      (b as? java.awt.event.ComponentListener)?.componentMoved(e)
    }
    public func componentShown(_ e: java.awt.event.ComponentEvent) {
      (a as? java.awt.event.ComponentListener)?.componentShown(e)
      (b as? java.awt.event.ComponentListener)?.componentShown(e)
    }
    public func componentHidden(_ e: java.awt.event.ComponentEvent) {
      (a as? java.awt.event.ComponentListener)?.componentHidden(e)
      (b as? java.awt.event.ComponentListener)?.componentHidden(e)
    }

    // =========================================================================
    // MARK: - FocusListener
    // =========================================================================

    public func focusGained(_ e: java.awt.event.FocusEvent) {
      (a as? java.awt.event.FocusListener)?.focusGained(e)
      (b as? java.awt.event.FocusListener)?.focusGained(e)
    }
    public func focusLost(_ e: java.awt.event.FocusEvent) {
      (a as? java.awt.event.FocusListener)?.focusLost(e)
      (b as? java.awt.event.FocusListener)?.focusLost(e)
    }

    // =========================================================================
    // MARK: - ItemListener
    // =========================================================================

    public func itemStateChanged(_ e: java.awt.event.ItemEvent) {
      (a as? java.awt.event.ItemListener)?.itemStateChanged(e)
      (b as? java.awt.event.ItemListener)?.itemStateChanged(e)
    }

    // =========================================================================
    // MARK: - KeyListener
    // =========================================================================

    public func keyTyped(_ e: java.awt.event.KeyEvent) {
      (a as? java.awt.event.KeyListener)?.keyTyped(e)
      (b as? java.awt.event.KeyListener)?.keyTyped(e)
    }
    public func keyPressed(_ e: java.awt.event.KeyEvent) {
      (a as? java.awt.event.KeyListener)?.keyPressed(e)
      (b as? java.awt.event.KeyListener)?.keyPressed(e)
    }
    public func keyReleased(_ e: java.awt.event.KeyEvent) {
      (a as? java.awt.event.KeyListener)?.keyReleased(e)
      (b as? java.awt.event.KeyListener)?.keyReleased(e)
    }

    // =========================================================================
    // MARK: - MouseListener
    // =========================================================================

    public func mouseClicked(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseListener)?.mouseClicked(e)
      (b as? java.awt.event.MouseListener)?.mouseClicked(e)
    }
    public func mousePressed(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseListener)?.mousePressed(e)
      (b as? java.awt.event.MouseListener)?.mousePressed(e)
    }
    public func mouseReleased(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseListener)?.mouseReleased(e)
      (b as? java.awt.event.MouseListener)?.mouseReleased(e)
    }
    public func mouseEntered(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseListener)?.mouseEntered(e)
      (b as? java.awt.event.MouseListener)?.mouseEntered(e)
    }
    public func mouseExited(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseListener)?.mouseExited(e)
      (b as? java.awt.event.MouseListener)?.mouseExited(e)
    }

    // =========================================================================
    // MARK: - MouseMotionListener
    // =========================================================================

    public func mouseDragged(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseMotionListener)?.mouseDragged(e)
      (b as? java.awt.event.MouseMotionListener)?.mouseDragged(e)
    }
    public func mouseMoved(_ e: java.awt.event.MouseEvent) {
      (a as? java.awt.event.MouseMotionListener)?.mouseMoved(e)
      (b as? java.awt.event.MouseMotionListener)?.mouseMoved(e)
    }

    // =========================================================================
    // MARK: - TextListener
    // =========================================================================

    public func textValueChanged(_ e: java.awt.event.TextEvent) {
      (a as? java.awt.event.TextListener)?.textValueChanged(e)
      (b as? java.awt.event.TextListener)?.textValueChanged(e)
    }

    // =========================================================================
    // MARK: - WindowListener
    // =========================================================================

    public func windowOpened(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowOpened(e)
      (b as? java.awt.event.WindowListener)?.windowOpened(e)
    }
    public func windowClosing(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowClosing(e)
      (b as? java.awt.event.WindowListener)?.windowClosing(e)
    }
    public func windowClosed(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowClosed(e)
      (b as? java.awt.event.WindowListener)?.windowClosed(e)
    }
    public func windowIconified(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowIconified(e)
      (b as? java.awt.event.WindowListener)?.windowIconified(e)
    }
    public func windowDeiconified(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowDeiconified(e)
      (b as? java.awt.event.WindowListener)?.windowDeiconified(e)
    }
    public func windowActivated(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowActivated(e)
      (b as? java.awt.event.WindowListener)?.windowActivated(e)
    }
    public func windowDeactivated(_ e: java.awt.event.WindowEvent) {
      (a as? java.awt.event.WindowListener)?.windowDeactivated(e)
      (b as? java.awt.event.WindowListener)?.windowDeactivated(e)
    }
  }
}
