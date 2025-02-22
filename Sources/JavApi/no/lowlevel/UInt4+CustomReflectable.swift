/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension UInt4: CustomReflectable {
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [
            ("value", value),
            ("lossless description", description),
            ("debug description", debugDescription)
        ]
        return Mirror(self, children: children)
    }
}
