import CombineViewModel
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

  @discardableResult
  func appendNew(title: String) -> Task {
    let task = Task(id: UUID(), title: title)
    tasks.append(task)
    return task
  }

  @discardableResult
  func delete(at index: Int) -> Task {
    tasks.remove(at: index)
  }

  enum Move {
    case append(Task, after: Task)
    case insert(Task, before: Task)
  }

  @discardableResult
  func move<Tasks: Collection>(_ newTasks: Tasks, to index: Int) -> [Move]? where Tasks.Element == Task {
    let oldIDs = newTasks.reduce(into: Set()) { $0.insert($1.id) }
    tasks.removeAll { oldIDs.contains($0.id) }

    guard !tasks.isEmpty else {
      tasks.append(contentsOf: newTasks)
      return nil
    }

    var moves: [Move] = []

    if index >= tasks.endIndex {
      for task in newTasks {
        let oldTask = tasks.last!
        tasks.append(task)
        moves.append(.append(task, after: oldTask))
      }
    } else {
      for task in newTasks.reversed() {
        let oldTask = tasks[index]
        tasks.insert(task, at: index)
        moves.append(.insert(task, before: oldTask))
      }
    }

    return moves
  }
}
