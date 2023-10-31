/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.nio.file {
  /// Utility type to work with paths
  public class Paths {
    /// Create a new path instance from given parts 
    public static func get (_ first : String, _ more : String...) -> Path{
      return _Path.of(first, more)
    }
  }
}
