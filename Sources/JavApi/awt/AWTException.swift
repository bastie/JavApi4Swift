/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt {

  public class AWTException: java.lang.Exception, @unchecked Sendable {

    public override init(_ message: String = "") {
      super.init(message)
    }
  }
}
