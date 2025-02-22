/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4 : CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return "0x" + String(value, radix: 16).uppercased()
    }
}
