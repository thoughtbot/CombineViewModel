@_exported import protocol Bindings.BindingOwner
import Bindings
import Combine

public protocol ViewModelObserver: BindingOwner {
  func updateView()
}

extension Reactive where Base: ViewModelObserver {
  var _updateView: BindingSink<Base, ()> {
    BindingSink(owner: base) { observer in
      observer.updateView()
    }
  }
}
