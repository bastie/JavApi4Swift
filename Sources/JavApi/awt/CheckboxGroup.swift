/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Mutually-exclusive group for `Checkbox` components — mirrors `java.awt.CheckboxGroup`.
  ///
  /// Add a `CheckboxGroup` to `Checkbox` instances to make them behave as radio buttons.
  @MainActor
  public final class CheckboxGroup {

    private weak var selected: Checkbox?

    public init() {}

    public func getSelectedCheckbox() -> Checkbox? { selected }

    public func setSelectedCheckbox(_ cb: Checkbox?) {
      // Deselect current
      selected?.setState(false, notifyGroup: false)
      selected = cb
      cb?.setState(true, notifyGroup: false)
    }

    /// Called by `Checkbox` when its state changes.
    internal func checkboxSelected(_ cb: Checkbox) {
      if selected !== cb {
        selected?.setState(false, notifyGroup: false)
        selected = cb
      }
    }
  }
}
