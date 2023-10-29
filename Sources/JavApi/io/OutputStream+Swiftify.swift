/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io.OutputStream {
  public static func nilOutputStream () -> java.io.OutputStream {
    return nullOutputStream()
  }
}
