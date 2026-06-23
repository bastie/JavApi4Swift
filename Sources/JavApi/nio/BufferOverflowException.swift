/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio {

  /// Unchecked exception thrown when a relative put operation reaches
  /// the source buffer's limit.
  ///
  /// - Since: Java 1.4
  open class BufferOverflowException : RuntimeException, @unchecked Sendable {
    public override init() {
      super.init()
    }
    public override init(_ message: String) {
      super.init(message)
    }
  }
}
