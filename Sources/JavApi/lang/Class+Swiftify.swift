/*
 * SPDX-FileCopyrightText: 2024-2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.lang.Class {
  
    /// Returns the simple class name of the given object, stripping any module prefix.
    ///
    /// On Apple platforms this matches the Objective-C class name. On Linux the Swift
    /// runtime qualifies type names with the module (e.g. `"JavApiTests.MyClass"`);
    /// this method strips that prefix so the result matches Java's `Class.getSimpleName()`.
    ///
    /// - Parameter object: Any reference-type instance.
    /// - Returns: The unqualified class name, e.g. `"MyClass"`.
    public static func getName(of object: AnyObject) -> String {
      let type: any AnyObject.Type = type(of: object)
      let fullName = "\(type)"
      // On Linux, type interpolation includes the module prefix (e.g. "JavApiTests.MyClass").
      // Strip the module prefix to match Java's simple class-name semantics.
      return fullName.components(separatedBy: ".").last ?? fullName
    }
}
