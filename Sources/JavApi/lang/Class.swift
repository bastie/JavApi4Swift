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
      throw Throwable.ClassNotFoundException("class \(className) not found")
      
      // 2. Klasse suchen:
      
      // 3. Instanz erstellen (optional):
      // if let instance = cls.init() as? YourProtocol {
      //     return instance
      // }
      
      //return cls
    }
    
    open func getName() -> String {
      let type = delegate.className(for: delegate) ?? "<unknown>"
      return "\(type)"
    }

    
  }
  
}
