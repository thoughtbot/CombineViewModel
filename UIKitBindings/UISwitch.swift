import Bindings
import UIKit

extension Reactive where Base: UISwitch {
  public var isOn: BindingSink<Base, Bool> {
    BindingSink(owner: base) { $0.isOn = $1 }
  }
}
