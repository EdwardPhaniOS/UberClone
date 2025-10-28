// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Firebase
import FirebaseAuth
import GeoFire

let DB_URL = "https://uberclone-c3f5e-default-rtdb.asia-southeast1.firebasedatabase.app/"
let DB_REF = Database.database(url: DB_URL).reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {

  static let shared: Service = Service()

  func fetchUserData(userId: String, completion: @escaping (User) -> Void) {
    REF_USERS.child(userId).observeSingleEvent(of: .value) { snapShot in
      guard let dict = snapShot.value as? [String: Any] else { return }
      let uid = snapShot.key
      let user = User(uuid: uid, dict: dict)
      completion(user)
    }
  }

  func fetchDrivers(location: CLLocation, completion: @escaping (User) -> Void) {
    let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)

    REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
      geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { driverId, driverLocation in
        fetchUserData(userId: driverId) { user in
          var driver = user
          driver.location = driverLocation
          completion(driver)
        }
      })
    }
  }
}
