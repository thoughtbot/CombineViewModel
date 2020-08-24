#if canImport(UIKit) && !os(watchOS)
import Bindings
import UIKit

@available(tvOS, unavailable)
extension Reactive where Base: UISwitch {
  public var isOn: BindingSink<Base, Bool> {
    BindingSink(owner: base) { $0.isOn = $1 }
  }
}
#endif // canImport(UIKit) && !os(watchOS)
