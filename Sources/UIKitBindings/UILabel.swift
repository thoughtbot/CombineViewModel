#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

extension Reactive where Base: UILabel {
  public var text: BindingSink<Base, String?> {
    BindingSink(owner: base) { $0.text = $1 }
  }
}
#endif // canImport(UIKit) && !os(watchOS)
