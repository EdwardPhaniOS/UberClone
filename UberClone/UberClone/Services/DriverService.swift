//
//  DriverService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Firebase
import FirebaseAuth
import GeoFire

protocol DriverService {
  func observeTrip(completion: @escaping (Trip) -> Void)
  func observeTripCancelled(trip: Trip, completion: @escaping () -> Void)
  func updateDriverLocation(location: CLLocation, completion: @escaping (Error?) -> Void)
  func updateTripState(trip: Trip, state: TripState, completion: @escaping (Error?, DatabaseReference) -> Void)
  func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void)
}

struct DefaultDriverService: DriverService {
  
  func observeTrip(completion: @escaping (Trip) -> Void) {
    FirebaseREF.trips.observe(.childAdded) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let passengerUid = snapshot.key
      let trip = Trip(passengerUid: passengerUid, dict: dict)
      completion(trip)
    }
  }

 
  func observeTripCancelled(trip: Trip, completion: @escaping () -> Void) {
    FirebaseREF.trips.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
      completion()
    }
  }
  
  func updateDriverLocation(location: CLLocation, completion: @escaping (Error?) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let geofire = GeoFire(firebaseRef: FirebaseREF.driverLocations)
    geofire.setLocation(location, forKey: uid, withCompletionBlock: completion)
  }
  
  func updateTripState(trip: Trip, state: TripState, completion: @escaping (Error?, DatabaseReference) -> Void) {
    FirebaseREF.trips.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
    
    if state == .completed {
      FirebaseREF.trips.child(trip.passengerUid).removeAllObservers()
    }
  }
  
  func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let passengerUid: String = trip.passengerUid
    let values: [String: Any] = [
      "state": TripState.accepted.rawValue,
      "driverUid": uid
    ]
    
    FirebaseREF.trips.child(passengerUid).updateChildValues(values, withCompletionBlock: completion)
  }
}
