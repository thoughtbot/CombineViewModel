import Combine
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

    updateView()
  }

  func updateView() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Task>()
    snapshot.appendSections([.tasks])
    snapshot.appendItems(taskList.tasks)
    dataSource.apply(snapshot)

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
