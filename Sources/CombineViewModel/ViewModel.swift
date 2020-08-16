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

      var observations: AnyPublisher<(Object, Observer?), Never>!

      let checkObserverReady: (Object) -> (Object, Observer?) = { [weak observer] object in
        if let observer = observer, observer.isReadyForUpdates {
          return (object, observer)
        } else {
          return (object, nil)
        }
      }

#if canImport(UIKit)
      if let viewController = observer as? UIViewController {
        dispatchPrecondition(condition: .onQueue(.main))
        viewController.hookViewDidLoad()

        observations = newValue.observe(on: DispatchQueue.main)
          .combineLatest(viewController.viewDidLoadPublisher) { object, _ in checkObserverReady(object) }
          .eraseToAnyPublisher()
      }
#endif

      if observations == nil {
        observations = newValue.observe(on: DispatchQueue.main)
          .map(checkObserverReady)
          .eraseToAnyPublisher()
      }

      observations
        .sink { _, observer in observer?.updateView() }
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
