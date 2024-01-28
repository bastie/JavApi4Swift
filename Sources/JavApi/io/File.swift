/*
 * SPDX-FileCopyrightText: 2023, 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Foundation

extension java.io {
  
  /// Abstraction of entry in file system like regular files, directory and other
  ///
  /// A ``File``  instance
  ///
  /// * SeeAlso: [Oracle JavaDoc](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/io/File.html)
  ///
  open class File {
    
    /// The delimter char for directory structure from `System.getProperty("file.separator")` or slash if not set as default value
    public static let separatorChar : Character = System.getProperty("file.separator", "/").charAt(0)
    
    /// The delimter  for directory structure from `System.getProperty("file.separator")` or slash if not set as default value
    public static let separator : String = System.getProperty("file.separator", "/")
    
    /// The delimter char for device list from `System.getProperty("path.separator")` or slash if not set as default value
    public static let pathSeparatorChar : Character = System.getProperty("path.separator", ":").charAt(0)
    
    /// The delimter for device list from `System.getProperty("path.separator")` or `:` if not set as default value
    public static let pathSeparator : String = System.getProperty("path.separator", ":")
    
    /// internal representation
    private var file : String
    
    /// Create a new File instance with given file name
    /// - Parameters:
    /// - qualifiedFileName name of node in FileSystem as String with qualified directory
    public init (_ qualifiedFileName : String) {
      self.file = qualifiedFileName
    }
    
    /// Tests whether can execute the file.
    ///
    /// - Returns true if executable
    public func canExecute () -> Bool {
      return FileManager.default.isExecutableFile(atPath: self.file)
    }
    
    /// Test whether can read the file.
    ///
    /// - Returns true if readable
    public func canRead () -> Bool {
      return FileManager.default.isReadableFile(atPath: self.file)
    }
    
    /// Tests whentther can write the file
    ///
    /// - Returns true if writable
    public func canWrite () -> Bool {
      return FileManager.default.isWritableFile(atPath: self.file)
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
    
    /// Check the exists of file / directory
    ///
    /// - Returns true if exists
    public func exists () -> Bool {
      return FileManager.default.fileExists(atPath: self.file)
    }
    
    /// Tests wheter the file is a directory
    ///
    /// - Returns true if it exists and is a directory
    public func isDirectory () -> Bool {
      var isDirectory : ObjCBool = true
      let exists = FileManager.default.fileExists(atPath: self.file, isDirectory: &isDirectory)
      return exists && isDirectory.boolValue
    }
    
    /// Test wheter the file is hidden
    ///
    /// - Returns true if the file is hidden
    public func isHidden () -> Bool {
      do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: self.file)
        let hidden = (fileAttributes [.extensionHidden] as? Int ?? 2)!
        return hidden == 0
      }
      catch {
        return false
      }
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
    
    /// Create the subdirectory without subdirectory
    /// - Returns true if created
    public func mkdir () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: false) {
        return true
      }
      return false
    }
    
    /// Create directory with all subdirectories
    /// - Returns true if all directories are created
    public func mkdirs () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: true) {
        return true
      }
      return false
    }

    /// Creates a java.nio.Path instance from file
    /// - Returns Path instance
    public func toPath () -> java.nio.file.Path {
      return java.nio.file.Paths.get (self.file)
    }
  } // EOT

} // EOP
