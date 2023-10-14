/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java {
  /// The Java base class implementation
  public enum lang{}
}
// TODO: Incubation exception handling
extension java.lang {
  public typealias Array = Swift.Array
  public typealias Cloneable = JavApi.Cloneable
  public typealias Exception = JavApi.Throwable
  public typealias System = JavApi.System
  public typealias String = Swift.String
  public typealias Throwable = JavApi.Throwable
}
