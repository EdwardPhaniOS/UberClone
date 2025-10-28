// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation

enum SignUpError: Error {
  
  case missingRequiredFields([String])
  case missingCurrentLocation

  var message: String {
    switch self {
    case .missingRequiredFields(let fieldNames):
      let joinedFieldNames = fieldNames.joined(separator:", ")
      return "\(joinedFieldNames) \(fieldNames.count > 1 ? "are" : "is") required."
    case .missingCurrentLocation:
      return "Can not determine current location"
    }
  }
}
