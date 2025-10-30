// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import CoreLocation

enum AccountType: Int {
  case passenger
  case driver
}

struct User {
  let uuid: String
  var accountType: AccountType!
  let email: String
  let fullName: String
  var location: CLLocation?

  init(uuid: String, dict: [String: Any]) {
    self.uuid = uuid
    self.email = dict["email"] as? String ?? ""
    self.fullName = dict["fullName"]  as? String ?? ""

    if let type = dict["accountType"] as? Int {
      self.accountType = AccountType(rawValue: type) ?? .passenger
    }
  }
}
