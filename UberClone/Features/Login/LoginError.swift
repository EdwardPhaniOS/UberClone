//  Created by Vinh Phan on 20/10/25.
//

import Foundation

enum LoginError: Error {
  case missingRequiredFields([String])
  case invalidFields([String])
  
  var message: String {
    switch self {
    case .missingRequiredFields(let fieldNames):
      let joinedFieldNames = fieldNames.joined(separator: ", ")
      return "\(joinedFieldNames) \(fieldNames.count > 1 ? "are" : "is") required."
    case .invalidFields(let fieldNames):
      let joinedFieldNames = fieldNames.joined(separator: ", ")
      return "\(joinedFieldNames) \(fieldNames.count > 1 ? "are" : "is") invalid."
    }
  }
}
