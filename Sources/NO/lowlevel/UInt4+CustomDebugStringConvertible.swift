/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4 : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "0x" + String(value, radix: 16).uppercased()
    }
}

