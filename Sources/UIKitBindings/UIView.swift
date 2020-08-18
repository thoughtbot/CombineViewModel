#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

extension Reactive where Base: UIView {
  public var isHidden: BindingSink<Base, Bool> {
    BindingSink(owner: base) { $0.isHidden = $1 }
  }
}
#endif // canImport(UIKit) && !os(watchOS)
