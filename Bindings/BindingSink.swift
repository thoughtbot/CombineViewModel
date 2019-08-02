import Combine

public final class BindingSink<Owner: BindingOwner, Input> {
  public typealias Failure = Never

  private(set) weak var owner: Owner?
  private let receiveCompletion: (Owner, Subscribers.Completion<Failure>) -> Void
  private let receiveValue: (Owner, Input) -> Void
  private var subscription: Subscription?

  public init(owner: Owner, receiveCompletion: @escaping (Owner, Subscribers.Completion<Failure>) -> Void = { _, _ in }, receiveValue: @escaping (Owner, Input) -> Void) {
    self.owner = owner
    self.receiveCompletion = receiveCompletion
    self.receiveValue = receiveValue
  }

  private func withOwner(_ body: (Owner) -> Void) {
    if let owner = owner {
      body(owner)
    } else {
      cancel()
    }
  }
}

extension BindingSink where Input == Void {
  public convenience init(owner: Owner, receiveCompletion: @escaping (Owner, Subscribers.Completion<Failure>) -> Void = { _, _ in }, receiveValue: @escaping (Owner) -> Void) {
    self.init(owner: owner, receiveCompletion: receiveCompletion, receiveValue: { owner, _ in receiveValue(owner) })
  }
}

extension BindingSink where Input == Never {
  public convenience init(owner: Owner, receiveCompletion: @escaping (Owner, Subscribers.Completion<Failure>) -> Void) {
    self.init(owner: owner, receiveCompletion: receiveCompletion, receiveValue: { _, _ in })
  }
}

extension BindingSink: Subscriber {
  public func receive(subscription: Subscription) {
    if owner != nil {
      subscription.request(.unlimited)
      self.subscription = subscription
    } else {
      subscription.cancel()
    }
  }

  public func receive(_ input: Input) -> Subscribers.Demand {
    withOwner { receiveValue($0, input) }
    return .max(1)
  }

  public func receive(completion: Subscribers.Completion<Failure>) {
    withOwner { receiveCompletion($0, completion) }
  }
}

extension BindingSink: Cancellable {
  public func cancel() {
    subscription?.cancel()
    subscription = nil
    owner = nil
  }
}

extension BindingSink: BindingSubscriber {
  @discardableResult
  public static func <~ <P: Publisher> (sink: BindingSink, publisher: P) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure
  {
    guard let owner = sink.owner else { return AnyCancellable({}) }
    let cancellable = AnyCancellable(sink)
    cancellable.store(in: &owner.subscriptions)
    publisher.subscribe(sink)
    return cancellable
  }
}
