// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation

struct User {
  let accountType: Int
  let email: String
  let fullName: String

  init(dict: [String: Any]) {
    self.accountType = dict["accountType"] as? Int ?? 0
    self.email = dict["email"] as? String ?? ""
    self.fullName = dict["fullName"]  as? String ?? ""
  }
}
