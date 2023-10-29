/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java {
  /// The namespace of IO types
  public enum io{
    public typealias Closeable = JavApi.Closeable
    public typealias Flushable = JavApi.Flushable
  }
}
