/*
 * SPDX-License-Identifier: MIT
 */
extension java.time.Instant: CustomReflectable {
  
  /// The custom mirror for this instance.
  ///
  /// If this type has value semantics, the mirror should be unaffected by
  /// subsequent mutations of the instance.
  public var customMirror: Mirror {
    var c = [(label: String?, value: Any)]()
    c.append((label: "second", value: self.second))
    c.append((label: "nano", value: self.nano))
    return Mirror(self, children: c, displayStyle: Mirror.DisplayStyle.struct)
  }
  
}
