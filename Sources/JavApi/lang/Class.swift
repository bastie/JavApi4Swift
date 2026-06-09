/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Foundation

extension java.lang {
  
  open class Class {
    
    let delegate : AnyClass
    internal init(delegate: AnyClass) {
      self.delegate = delegate
    }
    
    static func loadClass(named className: String) throws -> Class {
      /*
      let cls = java.io.File("/")
      let clss = type(of: cls) as! AnyClass
      print(clss)
      */
      for bundle in Bundle.allBundles {
        //print (bundle)
        if let clazz = bundle.classNamed(className) {
          let result = java.lang.Class(delegate: clazz)
          return result
        }
        //print ("--------------")
      }
      throw ClassNotFoundException("class \(className) not found")
      
      // 2. Klasse suchen:
      
      // 3. Instanz erstellen (optional):
      // if let instance = cls.init() as? YourProtocol {
      //     return instance
      // }
      
      //return cls
    }
    
    open func getName() -> String {
      #if canImport(ObjectiveC) // Apple-OSs
      let type = delegate.className(for: delegate) ?? "<unknown>"
      #else // Linux, BSD and so on
      let type = String(describing: type(of: delegate))
      #endif
      return "\(type)"
    }

    /// Returns the `Class` object associated with the class or interface with the given string name.
    ///
    /// - TODO: Full Swift reflection is not available; this implementation searches loaded Objective-C
    ///   bundles on Apple platforms. On Linux/Windows it always throws `ClassNotFoundException`.
    /// - Since: Java 1.0
    public static func forName(_ className: String) throws -> java.lang.Class {
      return try loadClass(named: className)
    }

    /// Returns the `ClassLoader` that loaded this class.
    ///
    /// - TODO: see ClassLoader.
    /// - Since: Java 1.0
    public func getClassLoader() -> java.lang.ClassLoader? {
      fatalError("TODO: see getClassLoader() ")
    }

    /// Returns the interfaces directly implemented by the class or interface represented by this object.
    ///
    /// - TODO: Swift reflection does not expose protocol conformances as `Class` objects.
    /// - Since: Java 1.0
    public func getInterfaces() -> [java.lang.Class] {
      fatalError("TODO: getInterfaces() — Swift reflection does not expose protocol conformances")
    }

    /// Returns the `Class` representing the superclass of the entity represented by this `Class`.
    ///
    /// - TODO: Swift reflection does not expose superclass as a `java.lang.Class` object generically.
    /// - Since: Java 1.0
    public func getSuperclass() -> java.lang.Class? {
      fatalError("TODO: getSuperclass() — Swift reflection does not expose superclass generically")
    }

    /// Returns `true` if this `Class` object represents an interface type.
    ///
    /// - TODO: Swift reflection does not distinguish protocols from classes in this context.
    /// - Since: Java 1.0
    public func isInterface() -> Bool {
      fatalError("TODO: isInterface() — Swift reflection cannot distinguish protocols from classes")
    }

    /// Creates a new instance of the class represented by this `Class` object.
    ///
    /// - TODO: Swift requires explicit initializer calls; generic `newInstance()` is not safely expressible.
    /// - Since: Java 1.0
    public func newInstance() throws -> AnyObject {
      fatalError("TODO: newInstance() — Swift requires explicit initializer calls")
    }

    /// Returns a string representation of this class object.
    ///
    /// - Since: Java 1.0
    public func toString() -> String {
      return "class \(getName())"
    }

  }
  
}
