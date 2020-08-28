import CombineViewModel
import UIKit
import os.log

final class TasksViewController: UITableViewController, ViewModelObserver {
  private class DataSource: UITableViewDiffableDataSource<Section, Task> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      true
    }
  }

  private enum Section {
    case tasks
  }

  private var dataSource: UITableViewDiffableDataSource<Section, Task>!
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()
  private let url = try! FileManager.default
    .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    .appendingPathComponent("tasks.json", isDirectory: false)
  @ViewModel private var taskList: TaskList

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    do {
      let data = try Data(contentsOf: url)
      let tasks = try decoder.decode([Task].self, from: data)
      taskList = TaskList(tasks: tasks)
    } catch {
      os_log(.error, "Error loading task list: %@", "\(error)")
      taskList = TaskList()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
      cell.textLabel?.text = item.title
      return cell
    }
    tableView.dragInteractionEnabled = true
    tableView.dragDelegate = self
    tableView.dropDelegate = self
  }

  func updateView() {
    let oldTasks = dataSource.snapshot().itemIdentifiers
    guard !taskList.tasks.difference(from: oldTasks).isEmpty else { return }

    var snapshot = NSDiffableDataSourceSnapshot<Section, Task>()
    snapshot.appendSections([.tasks])
    snapshot.appendItems(taskList.tasks)
    dataSource.apply(snapshot, animatingDifferences: view.window != nil)

    do {
      let data = try encoder.encode(taskList.tasks)
      try data.write(to: url)
    } catch {
      os_log(.error, "Error saving task list: %@", "\(error)")
    }
  }

  @IBAction func newTask(_ sender: Any?) {
    let alert = UIAlertController(
      title: "New Task",
      message: nil,
      preferredStyle: .alert
    )

    alert.addTextField { textField in
      textField.autocapitalizationType = .sentences
      textField.enablesReturnKeyAutomatically = true
      textField.returnKeyType = .done
    }

    let save = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
      guard let textField = alert?.textFields?.first else { return }
      self.saveNewTask(textField)
    }
    alert.addAction(save)

    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(cancel)

    present(alert, animated: true)
  }

  @objc func saveNewTask(_ textField: UITextField) {
    guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
      else { return }

    let task = taskList.appendNew(title: text)
    var snapshot = dataSource.snapshot()
    if snapshot.sectionIdentifiers.isEmpty {
      snapshot.appendSections([.tasks])
    }
    snapshot.appendItems([task])
    dataSource.apply(snapshot)
  }
}

private extension TasksViewController {
  func move<Tasks: Collection>(_ tasks: Tasks, to indexPath: IndexPath) where Tasks.Element == Task {
    if let moves = taskList.move(tasks, to: indexPath.row) {
      var snapshot = dataSource.snapshot()
      for move in moves {
        switch move {
        case let .append(task, after: otherTask):
          snapshot.moveItem(task, afterItem: otherTask)
        case let .insert(task, before: otherTask):
          snapshot.moveItem(task, beforeItem: otherTask)
        }
      }
      dataSource.apply(snapshot)
    }
  }
}

extension TasksViewController/*: UITableViewDelegate */ {
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "Delete") { [taskList] _, _, completion in
      let task = taskList.delete(at: indexPath.row)
      var snapshot = self.dataSource.snapshot()
      snapshot.deleteItems([task])
      self.dataSource.apply(snapshot, animatingDifferences: true)
      completion(true)
    }
    let configuration = UISwipeActionsConfiguration(actions: [delete])
    configuration.performsFirstActionWithFullSwipe = true
    return configuration
  }
}

extension TasksViewController: UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
    true
  }

  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    [taskDragItem(at: indexPath)]
  }

  func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
    [taskDragItem(at: indexPath)]
  }

  private func taskDragItem(at indexPath: IndexPath) -> UIDragItem {
    let task = taskList.tasks[indexPath.row]
    let item = UIDragItem(itemProvider: NSItemProvider())
    item.localObject = task
    return item
  }
}

extension TasksViewController: UITableViewDropDelegate {
  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    guard tableView.hasActiveDrag else {
      return UITableViewDropProposal(operation: .cancel)
    }

    if session.items.count > 1 {
      // .unspecified is required to support dropping multiple items:
      // https://twitter.com/smileyborg/status/879775985712975872
      return UITableViewDropProposal(operation: .move, intent: .unspecified)
    } else {
      return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
  }

  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    guard let indexPath = coordinator.destinationIndexPath else { return }
    let items = coordinator.session.items
    let tasks = items.map { $0.localObject as! Task }
    move(tasks, to: indexPath)
  }
}
