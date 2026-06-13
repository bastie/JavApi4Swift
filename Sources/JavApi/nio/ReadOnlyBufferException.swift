/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio.charset {

  /// - Since Java 1.4
  open class ReadOnlyBufferException : UnsupportedOperationException, @unchecked Sendable {
    
    public override init () {
      super.init()
    }
  }
}
