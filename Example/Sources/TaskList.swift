import Combine
import Foundation

struct Task: Hashable, Codable {
  var id: UUID
  var title: String
}

final class TaskList: ObservableObject {
  @Published private(set) var tasks: [Task]

  init(tasks: [Task] = []) {
    self.tasks = tasks
  }

  func appendNew(title: String) {
    let task = Task(id: UUID(), title: title)
    tasks.append(task)
  }
}
