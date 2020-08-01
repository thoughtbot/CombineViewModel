import Combine
import CombineViewModel
import UIKit

final class TasksViewController: UITableViewController, ViewModelObserver {
  private enum Section {
    case tasks
  }

  private var dataSource: UITableViewDiffableDataSource<Section, Task>!
  @ViewModel private var taskList: TaskList

  var subscriptions: Set<AnyCancellable> = []

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    taskList = TaskList()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
      cell.textLabel?.text = item.title
      return cell
    }
  }

  func updateView() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Task>()
    snapshot.appendSections([.tasks])
    snapshot.appendItems(taskList.tasks)
    dataSource.apply(snapshot)
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
