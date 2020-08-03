import CombineViewModel
import Foundation

final class Counter: ObservableObject {
  let defaultValue: Int
  @Published var value: Int

  init(value: Int, defaultValue: Int) {
    self.defaultValue = defaultValue
    self.value = value
  }

  var formattedValue: String {
    NumberFormatter.localizedString(
      from: NSNumber(value: value),
      number: .decimal
    )
  }

  var isDefault: Bool {
    value == defaultValue
  }

  func reset() {
    value = defaultValue
  }
}
