import Combine

infix operator <~

public protocol BindingSubscriber: Subscriber, Cancellable {
  static func <~ <P: Publisher> (subscriber: Self, source: P) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure
}
