#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

extension Reactive where Base: UIBarButtonItem {
  public var isEnabled: BindingSink<Base, Bool> {
    BindingSink(owner: base) { $0.isEnabled = $1 }
  }
}
#endif
