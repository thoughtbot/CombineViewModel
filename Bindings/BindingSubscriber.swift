import Combine

infix operator <~: DefaultPrecedence

public protocol BindingSubscriber: Subscriber, Cancellable {
  @discardableResult
  static func <~ <P: Publisher> (subscriber: Self, source: P) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure
}

extension Publisher {
  @discardableResult
  public static func ~> <B: BindingSubscriber> (source: Self, subscriber: B) -> AnyCancellable
    where Output == B.Input, Failure == B.Failure
  {
    subscriber <~ source
  }
}
