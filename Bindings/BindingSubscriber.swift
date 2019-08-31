import Combine

infix operator <~
infix operator ~>

public protocol BindingSubscriber: Subscriber, Cancellable {
  @discardableResult
  static func <~ <P: Publisher> (subscriber: Self, source: P) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure

  @discardableResult
  static func ~> <P: Publisher> (source: P, subscriber: Self) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure
}

extension BindingSubscriber {
  @discardableResult
  public static func ~> <P: Publisher> (source: P, subscriber: Self) -> AnyCancellable
    where P.Output == Input, P.Failure == Failure
  {
    subscriber <~ source
  }
}
