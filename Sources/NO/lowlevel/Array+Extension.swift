/*
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
extension Array {
  /// split array into chunks with over or undercut
  ///
  /// - Parameters
  ///     - size of chunks
  ///     - cut elements from before (negative times) or next (positive times) or not (zero times)
  /// - Returns array of chunks
  func chunked(size: Int, cut : Int = 0) -> [[Element]] {
    switch (cut > 0 ? 1 : cut < 0 ? -1 : 0) {
      
    case 0 :
      return stride(from: 0, to: count, by: size).map {
        Array(self[$0 ..< Swift.min($0 + size, count)])
      }
      
    case 1:
      var result : [[Element]] = self.chunked(size: size, cut: 0)
      
      for next in 1..<result.count {
        for i in 0..<cut {
          result[next-1].append(result[next][i])
        }
      }
      
      return result
      
    case -1: fallthrough
    default:
      var result : [[Element]] = self.chunked(size: size, cut: 0)
      let undercut = cut * -1
      for next in 0..<result.count-1 {
        for i in 1...undercut {
          result [next+1].insert(result[next][result[next].count-i], at: 0)
        }
      }
      return result
    }
  }
}
