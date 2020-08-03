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

  func move<Tasks: Collection>(_ newTasks: Tasks, to index: Int) where Tasks.Element == Task {
    let oldIDs = newTasks.reduce(into: Set()) { $0.insert($1.id) }
    tasks.removeAll { oldIDs.contains($0.id) }
    if index > tasks.endIndex {
      tasks.append(contentsOf: newTasks)
    } else {
      tasks.insert(contentsOf: newTasks, at: index)
    }
  }
}
