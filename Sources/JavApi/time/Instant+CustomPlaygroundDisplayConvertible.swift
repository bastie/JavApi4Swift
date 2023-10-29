/*
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: CustomPlaygroundDisplayConvertible {
  
  /// Returns the custom playground description for this instance.
  ///
  /// If this type has value semantics, the instance returned should be
  /// unaffected by subsequent mutations if possible.
  public var playgroundDescription: Any {
    return self.description
  }
  
}
