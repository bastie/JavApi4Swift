/*
 * SPDX-FileCopyrightText: 2024 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */


extension java.lang.Class {
  
    public static func getName(of object: AnyObject) -> String {
      let type: any AnyObject.Type = type(of: object)
      return "\(type)"
    }
}
