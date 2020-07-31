import Combine
import Dispatch
#if canImport(UIKit)
import UIKit
#endif

@propertyWrapper
public struct ViewModel<Object: ObservableObject> {
  private var object: Object!

  public init() {}

  @available(*, unavailable, message: "ViewModel can only be used by reference types.")
  public var wrappedValue: Object {
    get { fatalError("Accessing wrappedValue directly is not permitted.") }
    set { fatalError("Accessing wrappedValue directly is not permitted.") }
  }

  public static subscript<Observer: ViewModelObserver>(
    _enclosingInstance observer: Observer,
    wrapped wrappedValueKeyPath: ReferenceWritableKeyPath<Observer, Object>,
    storage storageKeyPath: ReferenceWritableKeyPath<Observer, Self>
  ) -> Object {
    get {
      observer[keyPath: storageKeyPath].object
    }
    set {
      guard observer[keyPath: storageKeyPath].object == nil else {
        preconditionFailure("ViewModel can only be assigned once.")
      }

      observer[keyPath: storageKeyPath].object = newValue

      func startObserving() {
        newValue.observe(on: DispatchQueue.main)
          .sink { [weak observer] _ in observer?.updateView() }
          .store(in: &observer.subscriptions)
      }

      if observer.isViewLoaded {
        startObserving()
      } else {
#if canImport(UIKit)
        if let viewController = observer as? UIViewController {
          let viewDidLoadObserver = ViewDidLoadObserver(viewController: viewController, onViewDidLoad: startObserving)
          viewDidLoadObserver.schedule(forMode: .common, in: .current)
        }
#endif
      }
    }
  }
}

extension ViewModel {
  @available(*, unavailable, message: "ViewModel can't be initialized with a default value — set the initial value inside an initializer instead.")
  public init(wrappedValue: Object) {
    fatalError()
  }
}
