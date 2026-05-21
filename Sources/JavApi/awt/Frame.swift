extension java.awt {
  
  @MainActor
  open class Frame: Container {
    public var title: String
    
    public init(_ title: String = "") {
      self.title = title
    }
    
    /// Macht das Fenster sichtbar — auf Apple öffnet das ein SwiftUI-Window
    open func setVisible(_ visible: Bool) {
      #if canImport(SwiftUI)
      if visible { AWTWindowHost.shared.show(self) }
      #endif
    }
    
    open func setSize(_ width: Int, _ height: Int) {
      bounds = java.awt.Rectangle(0, 0, width, height)
    }
  }
}
