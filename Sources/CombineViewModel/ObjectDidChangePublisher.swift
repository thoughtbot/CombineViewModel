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
    private var demand: Subscribers.Demand = .none
    private var subscriber: S?
    private var subscription: AnyCancellable?

    init(object: Object, scheduler: Context, subscriber: S) {
      self.object = object
      self.subscriber = subscriber

      let source = scheduler.scheduleEventSource { [weak self] _ in
        self?.serviceDemand()
      }

      self.subscription = object.objectWillChange.sink(
        receiveCompletion: { [weak self] _ in self?.finish() },
        receiveValue: { _ in source.signal() }
      )
    }

    func finish() {
      subscriber?.receive(completion: .finished)
      cancel()
    }

    func serviceDemand() {
      guard let subscriber = subscriber, let object = object else {
        cancel()
        return
      }

      guard demand > 0 else { return }
      self.demand -= 1
      self.demand += subscriber.receive(object)
    }
  }
}

extension ObjectDidChangePublisher.Subscription: Cancellable {
  func cancel() {
    subscriber = nil
    subscription = nil
  }
}

extension ObjectDidChangePublisher.Subscription: Subscription {
  func request(_ demand: Subscribers.Demand) {
    assert(demand > 0, "Demand must be positive")
    self.demand += demand
    serviceDemand()
  }
}
