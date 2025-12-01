//
//  AuthData.swift
//  UberClone
//
//  Created by Vinh Phan on 12/11/25.
//

import Foundation

struct AuthData {
  let uid: String
  let email: String?
  
  init(uid: String, email: String?) {
    self.uid = uid
    self.email = email
  }
}
