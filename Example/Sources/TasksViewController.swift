import Bindings
import Combine
import CombineExt
import CombineViewModel
import UIKit
import os.log

final class TasksViewController: UITableViewController, ViewModelObserver {
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

  var subscriptions: Set<AnyCancellable> = []

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

    dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
      cell.textLabel?.text = item.title
      return cell
    }
    tableView.dragInteractionEnabled = true
    tableView.dragDelegate = self
    tableView.dropDelegate = self
  }

  func updateView() {
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

    let save = UIAlertAction(title: "Save", style: .default) { _ in
      self.saveNewTask(alert.textFields!.first!)
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

    taskList.appendNew(title: text)
  }
}

private extension TasksViewController {
  func moveTasks<Tasks: Collection>(to indexPath: IndexPath) -> BindingSink<TasksViewController, Tasks> where Tasks.Element == Task {
    BindingSink(owner: self) { $0.taskList.move($1, to: indexPath.row) }
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
    let provider = NSItemProvider()
    provider.registerDataRepresentation(forTypeIdentifier: "\(Bundle.main.bundleIdentifier!).task", visibility: .ownProcess) { completion -> Progress? in
      do {
        let data = try self.encoder.encode(task)
        completion(data, nil)
      } catch {
        completion(nil, error)
      }
      return nil
    }
    return UIDragItem(itemProvider: provider)
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

    moveTasks(to: indexPath) <~ coordinator.session.items
      .map { item in
        item.itemProvider
          .dataRepresentationPublisher(forTypeIdentifier: "\(Bundle.main.bundleIdentifier!).task")
          .decode(type: Task.self, decoder: decoder)
      }
      .zip()
      .logError("Failed to drop task item")
      .receive(on: DispatchQueue.main)
  }
}
