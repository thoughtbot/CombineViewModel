#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

extension Reactive where Base: UIViewController {
  @available(tvOS, unavailable)
  public var toolbarItems: BindingSink<Base, [UIBarButtonItem]?> {
    BindingSink(owner: base) { $0.toolbarItems = $1 }
  }
}
#endif
