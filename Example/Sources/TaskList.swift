import Combine
import Foundation

struct Task: Hashable {
  var id: UUID
  var title: String
}

final class TaskList: ObservableObject {
  @Published private(set) var tasks: [Task] = []

  func appendNew(title: String) {
    let task = Task(id: UUID(), title: title)
    tasks.append(task)
  }
}
