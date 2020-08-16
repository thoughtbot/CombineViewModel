import CombineViewModel
import UIKit

final class CounterViewController: UITableViewController, ViewModelObserver {
  @IBOutlet private var resetItem: UIBarButtonItem!
  @IBOutlet private var stepper: UIStepper!
  @IBOutlet private var valueLabel: UILabel!

  @ViewModel private var counter: Counter

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    counter = Counter(
      value: UserDefaults.standard.integer(forKey: "counterValue"),
      defaultValue: 0
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    stepper.maximumValue = .infinity
    stepper.minimumValue = -.infinity
  }

  func updateView() {
    resetItem.isEnabled = !counter.isDefault
    stepper.value = Double(counter.value)
    valueLabel.text = counter.formattedValue
    UserDefaults.standard.set(counter.value, forKey: "counterValue")
  }

  @IBAction func reset(_ sender: Any?) {
    counter.reset()
  }

  @IBAction func step(_ stepper: UIStepper) {
    counter.value = Int(stepper.value)
  }
}
