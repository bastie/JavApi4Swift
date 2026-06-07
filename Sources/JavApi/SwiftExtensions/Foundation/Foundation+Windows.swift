/*
 * SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: 0BSD
 */

// - Note: I do not need to work with `#if` but I don't want override the M_E constant for all systems
#if os(Windows)
let M_E: Double = 2.718281828459045235360287471352662497757247093699959574966967627
#endif
