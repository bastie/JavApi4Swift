/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  
  /// Abstraction of entry in file system like regular files, directory and other
  open class File {
    
    private var file : String
    
    /// Create a new File instance with given file name
    /// - Parameters file name
    public init (_ qualifiedFileName : String) {
      self.file = qualifiedFileName
      
    }
    
    /// Check the exists of file / directory
    /// - Returns true if exists
    public func exists () -> Bool {
      FileManager.default.fileExists(atPath: self.file)
    }
    
    /// Create directory with all subdirectories
    /// - Returns true if all directories are created
    public func mkdirs () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: true) {
        return true
      }
      return false
    }
    
    /// Create the subdirectory without subdirectory
    /// - Returns true if created
    public func mkdir () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: false) {
        return true
      }
      return false
    }
    
    /// Returns the size in bytes of file
    /// - Returns count of bytes in file or 0 
    public func length () -> Int64 {
      do {
        let attribute = try FileManager.default.attributesOfItem(atPath: self.file)
        if let length = attribute[FileAttributeKey.size] as? Int64 {
          return length
        }
        return 0
      }
      catch {
        return 0
      }
    }
    /// Delete the file
    /// - Returns true if deleted
    public func delete () -> Bool {
      do {
        try FileManager.default.removeItem(atPath: self.file)
        return true
      }
      catch {
        return false
      }
    }
    /// Creates a java.nio.Path instance from file
    /// - Returns Path instance
    public func toPath () -> java.nio.file.Path {
      return java.nio.file.Paths.get (self.file)
    }
  } // EOT

} // EOP
