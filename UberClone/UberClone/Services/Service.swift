// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Firebase
import FirebaseAuth
import GeoFire

let DB_URL = "https://uberclone-c3f5e-default-rtdb.asia-southeast1.firebasedatabase.app/"
let DB_REF = Database.database(url: DB_URL).reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

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

  func uploadTrip(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
    let destinationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]

    let values: [String: Any] = [
      "pickupCoordinates": pickupArray,
      "destinationCoordinates": destinationArray,
      "state": TripState.requested.rawValue
    ]

    REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
  }

  func observeTrip(completion: @escaping (Trip) -> Void) {
    REF_TRIPS.observe(.childAdded) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let passengerUid = snapshot.key
      let trip = Trip(passengerUid: passengerUid, dict: dict)
      completion(trip)
    }
  }

  func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let passengerUid: String = trip.passengerUid
    let values: [String: Any] = [
      "state": TripState.accepted.rawValue,
      "driverUid": uid
    ]
    REF_TRIPS.child(passengerUid).updateChildValues(values, withCompletionBlock: completion)
  }

  func observeCurrentTrip(completion: @escaping (Trip) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    REF_TRIPS.child(uid).observe(.value) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let uid = snapshot.key
      let trip = Trip(passengerUid: uid, dict: dict)
      completion(trip)
    }
  }
  
  func deleteTrip(completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    REF_TRIPS.child(uid).removeValue(completionBlock: completion)
  }
  
  func observeTripCancelled(trip: Trip, completion: @escaping () -> Void) {
    REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
      completion()
    }
  }
  
  func updateDriverLocation(location: CLLocation) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
    geofire.setLocation(location, forKey: uid)
  }
  
  func updateTripState(trip: Trip, state: TripState) {
    REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue)
  }
}
