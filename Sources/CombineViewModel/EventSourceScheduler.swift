import Combine

public protocol EventSourceScheduler: Scheduler {
  associatedtype EventSourceOptions = Never
  associatedtype EventSourceType: EventSource

  func scheduleEventSource(
    options: EventSourceOptions?,
    eventHandler: @escaping (EventSourceType) -> Void
  ) -> EventSourceType
}

extension EventSourceScheduler {
  public func scheduleEventSource(
    eventHandler: @escaping (EventSourceType) -> Void
  ) -> EventSourceType {
    scheduleEventSource(options: nil, eventHandler: eventHandler)
  }
}
