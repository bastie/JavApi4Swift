/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.beans {

  /// A full custom GUI editor for a JavaBean.
  ///
  /// In Java, `Customizer` extends `java.awt.Component`. In JavApi⁴Swift it is
  /// a plain protocol — conforming types should also be (or wrap) a UI
  /// component, but the protocol itself carries no AWT superclass constraint.
  ///
  /// - Since: Java 1.1
  public protocol Customizer: AnyObject {

    /// Tells the customizer which bean instance to edit.
    func setObject(_ bean: AnyObject)

    /// Registers a listener that is notified after the user changes a property.
    func addPropertyChangeListener(_ listener: PropertyChangeListener)

    /// Removes a previously registered property-change listener.
    func removePropertyChangeListener(_ listener: PropertyChangeListener)
  }
}
