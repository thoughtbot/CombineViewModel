import Bindings
import UIKit

extension Reactive where Base: UIControl {
  public var isEnabled: BindingSink<Base, Bool> {
    BindingSink(owner: base) { $0.isEnabled = $1 }
  }
}
