/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// needed to use ==
extension UInt4 : Equatable {
    /// Implementing the ```Equatable``` protocol to use ```==``` in Code
    static public func ==(lhs: UInt4, rhs: UInt4) -> Bool {
        return lhs.value == rhs.value
    }
}

