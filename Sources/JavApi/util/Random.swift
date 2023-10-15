/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension java.util {
  
  /// Type to create pseudo random values
  public class Random {
    
    /// Create a new int in full range of int values
    public func nextInt () -> Int {
      Int.random(in: Int.min...Int.max)
    }
  }
}
