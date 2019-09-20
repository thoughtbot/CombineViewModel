import Bindings
import UIKit

extension Reactive where Base: UITextField {
  public var placeholder: BindingSink<Base, String?> {
    BindingSink(owner: base) { $0.placeholder = $1 }
  }

  public var attributedPlaceholder: BindingSink<Base, NSAttributedString?> {
    BindingSink(owner: base) { $0.attributedPlaceholder = $1 }
  }
}
