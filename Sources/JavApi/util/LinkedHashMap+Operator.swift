/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util.LinkedHashMap {
  static func == <Key: Equatable, Value: Equatable>(lhs: java.util.LinkedHashMap<Key, Value>, rhs: java.util.LinkedHashMap<Key, Value>) -> Bool {
    lhs.sortedKeyCollection == rhs.sortedKeyCollection && lhs.delegateDictionary == rhs.delegateDictionary
  }
  
  static func != <Key: Equatable, Value: Equatable>(lhs: java.util.LinkedHashMap<Key, Value>, rhs: java.util.LinkedHashMap<Key, Value>) -> Bool {
    lhs.sortedKeyCollection != rhs.sortedKeyCollection || lhs.delegateDictionary != rhs.delegateDictionary
  }
}

