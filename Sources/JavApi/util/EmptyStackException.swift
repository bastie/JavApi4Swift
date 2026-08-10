/*
 * SPDX-FileCopyrightText: 2023-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {
  
  /// Exception throw to indicate `Stack` is empty.
  ///
  /// - See: ``Stack``
  open class EmptyStackException : RuntimeException, @unchecked Sendable {
    
    /// Construct a instance without message.
    public override init () {
      super.init()
    }
  }
}
