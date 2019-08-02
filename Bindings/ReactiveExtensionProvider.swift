import Foundation

public protocol ReactiveExtensionProvider {}

public struct Reactive<Base> {
  public let base: Base

  fileprivate init(_ base: Base) {
    self.base = base
  }
}

extension ReactiveExtensionProvider {
  public var reactive: Reactive<Self> {
    Reactive(self)
  }

  public static var reactive: Reactive<Self>.Type {
    Reactive<Self>.self
  }
}

extension NSObject: ReactiveExtensionProvider {}
