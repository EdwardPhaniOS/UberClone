// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import CoreLocation

enum AccountType: Int {
  case passenger
  case driver
}

class User {
  let uuid: String
  var accountType: AccountType!
  let email: String
  let fullName: String
  var location: CLLocation?
  var homeLocation: String?
  var workLocation: String?
  
  var firstInitial: String { return String(fullName.prefix(1)) }

  init(uuid: String, dict: [String: Any]) {
    self.uuid = uuid
    self.email = dict["email"] as? String ?? ""
    self.fullName = dict["fullName"]  as? String ?? ""

    if let type = dict["accountType"] as? Int {
      self.accountType = AccountType(rawValue: type) ?? .passenger
    }
    
    if let homeLocation = dict["homeLocation"] as? String {
      self.homeLocation = homeLocation
    }
    
    if let workLocation = dict["workLocation"] as? String {
      self.workLocation = workLocation
    }
  }
}

extension User: Equatable {
  static func == (lhs: User, rhs: User) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}

extension User {
  static var mock: User {
    let dict: [String: Any] = [
      "fullName": "Vinh Phan",
      "email": "Vinh@nomail.com"
    ]
    return User(uuid: UUID().uuidString, dict: dict)
  }
}
