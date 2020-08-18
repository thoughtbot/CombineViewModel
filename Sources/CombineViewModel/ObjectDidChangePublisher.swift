import Combine

extension ObservableObject {
  public func observe<S: EventSourceScheduler>(
    on scheduler: S,
    options: S.EventSourceOptions? = nil
  ) -> ObjectDidChangePublisher<Self, S> {
    ObjectDidChangePublisher(object: self, scheduler: scheduler)
  }
}

public struct ObjectDidChangePublisher<Object: ObservableObject, Context: EventSourceScheduler>: Publisher {
  public typealias Output = Object
  public typealias Failure = Never

  public let object: Object
  public let scheduler: Context

  public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    let subscription = Subscription(object: object, scheduler: scheduler, subscriber: subscriber)
    subscriber.receive(subscription: subscription)
  }
}

private extension ObjectDidChangePublisher {
  final class Subscription<S: Subscriber> where S.Input == Output, S.Failure == Failure {
    private weak var object: Object?

    @UnfairAtomic private var state: (
      demand: Subscribers.Demand,
      subscriber: S?,
      subscription: AnyCancellable?
    )

    init(object: Object, scheduler: Context, subscriber: S) {
      weak var weakSelf: Subscription?

      let source = scheduler.scheduleEventSource { _ in
        weakSelf?.serviceDemand()
      }

      let subscription = object.objectWillChange.sink(
        receiveCompletion: { _ in weakSelf?.finish() },
        receiveValue: { _ in source.signal() }
      )

      self.object = object
      self._state = UnfairAtomic((.none, subscriber, subscription))
      weakSelf = self
    }

    func finish() {
      if case let (_, subscriber?, _) = $state.swap((.none, nil, nil)) {
        subscriber.receive(completion: .finished)
      }
    }

    func serviceDemand() {
      guard let output = object else {
        finish()
        return
      }

      let subscriber = $state.withLock { state -> S? in
        guard let subscriber = state.subscriber, state.demand > 0 else {
          return nil
        }

        state.demand -= 1
        return subscriber
      }

      if let subscriber = subscriber {
        let newDemand = subscriber.receive(output)

        if newDemand > 0 {
          state.demand += newDemand
        }
      }
    }
  }
}

extension ObjectDidChangePublisher.Subscription: Cancellable {
  func cancel() {
    state = (.none, nil, nil)
  }
}

extension ObjectDidChangePublisher.Subscription: Subscription {
  func request(_ demand: Subscribers.Demand) {
    assert(demand > 0, "Demand must be positive")
    state.demand += demand
    serviceDemand()
  }
}
