/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io.File {
  /// Returns a result with information about file is only root directory.
  /// - Returns .success(true) if is root directory and .success(false) if is no root directory && .failure(Error) if unknown
  internal func isRootDirectory() -> Result<Bool,Error> {
#if os(WASI)
    return .failure(java.lang.Throwable.UnsupportedOperationException())
#endif
#if os(PS4)
    return .failure(java.lang.Throwable.UnsupportedOperationException())
#endif
#if os(Cygwin)
    let url = URL(fileURLWithPath: self.file)
    if url.pathComponents.count == 1 && url.path.contains(":") && self.file.count == 2{
      return .success(true)
    }
    return .success (false)
#else
    if self.file == "/" {
      return .success(true)
    }
    return .success (false)
#endif
  }
  
}
