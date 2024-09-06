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
    open func canExecute () -> Bool {
      return FileManager.default.isExecutableFile(atPath: self.file)
    }
    
    /// Test whether can read the file.
    ///
    /// - Returns true if readable
    open func canRead () -> Bool {
      return FileManager.default.isReadableFile(atPath: self.file)
    }
    
    /// Tests whentther can write the file
    ///
    /// - Returns true if writable
    open func canWrite () -> Bool {
      return FileManager.default.isWritableFile(atPath: self.file)
    }
    
    /// Delete the file
    /// - Returns true if deleted
    open func delete () -> Bool {
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
    open func exists () -> Bool {
      return FileManager.default.fileExists(atPath: self.file)
    }
    
    /// Tests wheter the file is a directory
    ///
    /// - Returns true if it exists and is a directory
    open func isDirectory () -> Bool {
      var isDirectory : ObjCBool = true
      let exists = FileManager.default.fileExists(atPath: self.file, isDirectory: &isDirectory)
      return exists && isDirectory.boolValue
    }
    
    /// Test wheter the file is hidden
    ///
    /// - Returns true if the file is hidden
    open func isHidden () -> Bool {
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
    open func length () -> Int64 {
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
    open func mkdir () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: false) {
        return true
      }
      return false
    }
    
    /// Create directory with all subdirectories
    /// - Returns true if all directories are created
    open func mkdirs () -> Bool {
      if let _ = try? FileManager.default.createDirectory(atPath: self.file, withIntermediateDirectories: true) {
        return true
      }
      return false
    }

    /// Creates a java.nio.Path instance from file
    /// - Returns Path instance
    open func toPath () -> java.nio.file.Path {
      return java.nio.file.Paths.get (self.file)
    }

    open func getPath () -> String {
      return self.toPath().toString()
    }
    open func toString () -> String {
      return getPath()
    }
    
    open func getAbsoluteFile() -> java.io.File {
      return java.io.File (self.getPath()) // TODO: TEST IT
    }
    
    open func getName () -> String {
      if 0 == self.toString().count {
        return ""
      }
      else {
        let url = URL(fileURLWithPath: self.getAbsoluteFile().toString())
        let fileNameWithExtension = url.lastPathComponent
        return fileNameWithExtension
      }
    }
    
    /// List all files of directory.
    /// If self isn't a directory returns ``nil``
    /// - Returns array of directory entries or ``nil``
    open func listFiles () -> [java.io.File]? {
      guard self.isDirectory() else {
        return nil
      }
      
      if let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: self.getAbsoluteFile().toString()) {
        var result : [java.io.File] = [java.io.File]()
        for nextFile in directoryContents {
          result.append(java.io.File(nextFile))
        }
        return result
      }
      return nil
    }
    
    /// List all files of directory filtered by given ``FileFilter``
    /// If self isn't a directory returns ``nil``
    /// - Returns array of directory entries or ``nil``
    open func listFiles (_ fileFilter : (any java.io.FileFilter)?) -> [java.io.File]? {
      if let allFiles = self.listFiles() {
        if let fileFilter {
          var result = [java.io.File]()
          for nextFile in allFiles {
            if fileFilter.accept(nextFile) {
              result.append(nextFile)
            }
          }
          return result
        }
        else {
          return allFiles
        }
      }
      else {
        return nil
      }
    }  } // EOT

} // EOP
