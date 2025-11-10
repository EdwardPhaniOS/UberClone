//
//  PassengerService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Firebase
import FirebaseAuth
import GeoFire

protocol PassengerService {
  func fetchDrivers(location: CLLocation, completion: @escaping (User) -> Void)
  func uploadTrip(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Error?, DatabaseReference) -> Void)
  func observeCurrentTrip(completion: @escaping (Trip) -> Void)
  func deleteTrip(completion: @escaping (Error?, DatabaseReference) -> Void)
  func saveLocation(type: LocationType, location: String, completion: @escaping (Error?, DatabaseReference) -> Void)
}

struct DefaultPassengerService: PassengerService {
  private let userSerivce: UserService
  
  init(userSerivce: UserService) {
    self.userSerivce = userSerivce
  }
  
  func fetchDrivers(location: CLLocation, completion: @escaping (User) -> Void) {
    let geofire = GeoFire(firebaseRef: FirebaseREF.driverLocations)
    FirebaseREF.driverLocations.observe(.value) { snapshot in
      geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { driverId, driverLocation in
        userSerivce.fetchUserData(userId: driverId) { user in
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

    FirebaseREF.trips.child(uid).updateChildValues(values, withCompletionBlock: completion)
  }
  
  func observeCurrentTrip(completion: @escaping (Trip) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    FirebaseREF.trips.child(uid).observe(.value) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let uid = snapshot.key
      let trip = Trip(passengerUid: uid, dict: dict)
      completion(trip)
    }
  }
  
  func deleteTrip(completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    FirebaseREF.trips.child(uid).removeValue(completionBlock: completion)
  }
  
  func saveLocation(type: LocationType, location: String, completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let key: String = type == .home ? "homeLocation" : "workLocation"
    FirebaseREF.users.child(uid).child(key).setValue(location, withCompletionBlock: completion)
  }
  
  
}
