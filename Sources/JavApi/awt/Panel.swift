/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  /// Generic container with a FlowLayout default.
  ///
  /// Panel is the simplest concrete Container.
  /// It differs from Container only in having FlowLayout as the explicit default.
  open class Panel: Container {

    public override init() {
      super.init()
      setLayout(java.awt.FlowLayout())
    }

    public init(_ layout: java.awt.LayoutManager) {
      super.init()
      setLayout(layout)
    }
  }
}
