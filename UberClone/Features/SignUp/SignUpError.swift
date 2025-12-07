//  Created by Vinh Phan on 20/10/25.
//

import Foundation

enum SignUpError: Error {
  
  case missingRequiredFields([String])
  case missingCurrentLocation

  var message: String {
    switch self {
    case .missingRequiredFields(let fieldNames):
      let joinedFieldNames = fieldNames.joined(separator: ", ")
      return "\(joinedFieldNames) \(fieldNames.count > 1 ? "are" : "is") required."
    case .missingCurrentLocation:
      return "Can not determine current location"
    }
  }
}
