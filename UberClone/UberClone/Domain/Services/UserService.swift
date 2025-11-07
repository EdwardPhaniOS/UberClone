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

