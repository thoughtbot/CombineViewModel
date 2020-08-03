import Combine
import Foundation

extension NSItemProvider {
  func dataRepresentationPublisher(forTypeIdentifier typeIdentifier: String) -> Future<Data, Error> {
    Future { promise in
      self.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, error in
        if let error = error {
          promise(.failure(error))
        } else if let data = data {
          promise(.success(data))
        } else {
          preconditionFailure("Expected either data or error.")
        }
      }
    }
  }
}
