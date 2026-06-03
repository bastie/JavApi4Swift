/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.lang.Class {
  
    public static func getName(of object: AnyObject) -> String {
      let type: any AnyObject.Type = type(of: object)
      let fullName = "\(type)"
      // On Linux, type interpolation includes the module prefix (e.g. "JavApiTests.MyClass").
      // Strip the module prefix to match Java's simple class-name semantics.
      return fullName.components(separatedBy: ".").last ?? fullName
    }
}
