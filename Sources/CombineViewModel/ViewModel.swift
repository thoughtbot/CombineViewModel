import Combine
import Dispatch
#if canImport(UIKit)
import CombineViewModelObjC
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

      var objectDidChange: AnyPublisher<(), Never>!

#if canImport(UIKit)
      if let viewController = observer as? UIViewController {
        dispatchPrecondition(condition: .onQueue(.main))
        _combinevm_hook_viewDidLoad(viewController)

        objectDidChange = newValue.observe(on: DispatchQueue.main)
          .combineLatest(viewController.viewDidLoadPublisher) { _, _ in }
          .eraseToAnyPublisher()
      }
#endif

      if objectDidChange == nil {
        objectDidChange = newValue.observe(on: DispatchQueue.main)
          .map { _ in }
          .eraseToAnyPublisher()
      }

      objectDidChange
        .sink { [weak observer] in observer?.updateView() }
        .store(in: &observer.subscriptions)
    }
  }
}

extension ViewModel {
  @available(*, unavailable, message: "ViewModel can't be initialized with a default value — set the initial value inside an initializer instead.")
  public init(wrappedValue: Object) {
    fatalError()
  }
}
