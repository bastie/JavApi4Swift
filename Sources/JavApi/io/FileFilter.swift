/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  /// Filter for files, usually use with File.listFiles function
  public protocol FileFilter {
    
    associatedtype FileFilter: java.io.FileFilter
    
    /// Check the given `file` to be accepted or not
    /// - Parameter file to check
    /// - Returns `bool` value to be accept this file
    func accept (_ file : java.io.File) -> Bool
  }
}

