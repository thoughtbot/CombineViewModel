import Bindings
import UIKit

extension Reactive where Base: UITextField {
  public var text: BindingSink<Base, String?> {
    BindingSink(owner: base) { $0.text = $1 }
  }

  public var attributedText: BindingSink<Base, NSAttributedString?> {
    BindingSink(owner: base) { $0.attributedText = $1 }
  }

  public var placeholder: BindingSink<Base, String?> {
    BindingSink(owner: base) { $0.placeholder = $1 }
  }

  public var attributedPlaceholder: BindingSink<Base, NSAttributedString?> {
    BindingSink(owner: base) { $0.attributedPlaceholder = $1 }
  }
}
