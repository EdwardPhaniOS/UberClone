//
//  UserService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import Firebase

protocol UserService {
  func fetchUserData(userId: String, completion: @escaping (User) -> Void)
  func updateUserData(userId: String, values: [String: Any], completion: @escaping (Error?, DatabaseReference) -> Void)
}

struct DefaultUserService: UserService {

  func fetchUserData(userId: String, completion: @escaping (User) -> Void) {
    FirebaseREF.users.child(userId).observeSingleEvent(of: .value) { snapShot in
      guard let dict = snapShot.value as? [String: Any] else { return }
      let uid = snapShot.key
      let user = User(uuid: uid, dict: dict)
      completion(user)
    }
  }
  
  func updateUserData(userId: String, values: [String: Any], completion: @escaping (Error?, DatabaseReference) -> Void) {
    FirebaseREF.users.child(userId).updateChildValues(values, withCompletionBlock: completion)
  }
}
