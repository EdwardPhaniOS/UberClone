// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import CoreLocation

struct User {
  let uuid: String
  let accountType: Int
  let email: String
  let fullName: String
  var location: CLLocation?

  init(uuid: String, dict: [String: Any]) {
    self.uuid = uuid
    self.accountType = dict["accountType"] as? Int ?? 0
    self.email = dict["email"] as? String ?? ""
    self.fullName = dict["fullName"]  as? String ?? ""
  }
}
