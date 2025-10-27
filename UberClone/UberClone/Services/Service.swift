// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Firebase
import FirebaseAuth

let DB_URL = "https://uberclone-c3f5e-default-rtdb.asia-southeast1.firebasedatabase.app/"
let DB_REF = Database.database(url: DB_URL).reference()
let REF_USERS = DB_REF.child("users")

struct Service {

  static let shared: Service = Service()

  func fetchUserData(completion: @escaping (User) -> Void) {
    guard let currentUserId = Auth.auth().getUserID() else { return }
    REF_USERS.child(currentUserId).observeSingleEvent(of: .value) { snapShot in
      guard let dict = snapShot.value as? [String: Any] else { return }
      let user = User(dict: dict)
      completion(user)
    }
  }
}
