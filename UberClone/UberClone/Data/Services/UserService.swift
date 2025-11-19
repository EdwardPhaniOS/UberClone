//
//  UserService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import Firebase

protocol UserService {
  func fetchUserData(userId: String) async throws -> User
  
  func updateUserData(userId: String, values: [String: Any]) async throws
}

struct DefaultUserService: UserService {
  
  func fetchUserData(userId: String) async throws -> User {
    let event = await FirebaseREF.users.child(userId).observeSingleEventAndPreviousSiblingKey(of: .value)
    let snapShot = event.0
    let dict = snapShot.value as! [String: Any]
    let uid = snapShot.key
    let user = User(uuid: uid, dict: dict)
    
    return user
  }
  
  func updateUserData(userId: String, values: [String: Any]) async throws {
    try await FirebaseREF.users.child(userId).updateChildValues(values)
  }
}
