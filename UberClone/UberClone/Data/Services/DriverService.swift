//
//  DriverService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Firebase
import FirebaseAuth
import GeoFire
import Combine

protocol DriverService {
  @discardableResult
  func tripPublisher() -> AnyPublisher<Trip, Error>
  
  func tripCancelPublisher(trip: Trip) -> AnyPublisher<Void, Error>
  
  func updateDriverLocation(location: CLLocation) async throws
  
  func updateTripState(trip: Trip, state: TripState) async throws
  
  func acceptTrip(trip: Trip) async throws
  
  func removeAllListener()
}

class DefaultDriverService: DriverService {
  
  @discardableResult
  func tripPublisher() -> AnyPublisher<Trip, Error> {
    let publisher = PassthroughSubject<Trip, Error>()
    
    FirebaseREF.trips.observe(.childAdded) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let passengerUid = snapshot.key
      let trip = Trip(passengerUid: passengerUid, dict: dict)
      publisher.send(trip)
    }
    
    return publisher.eraseToAnyPublisher()
  }
  
  func tripCancelPublisher(trip: Trip) -> AnyPublisher<Void, Error> {
    let publisher = PassthroughSubject<Void, Error>()
    FirebaseREF.trips.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { _ in
      publisher.send(Void())
    }
    
    return publisher.eraseToAnyPublisher()
  }
  
  func updateDriverLocation(location: CLLocation) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let geofire = GeoFire(firebaseRef: FirebaseREF.driverLocations)
    return try await geofire.setLocation(location, forKey: uid)
  }
  
  func updateTripState(trip: Trip, state: TripState) async throws {
    try await FirebaseREF.trips.child(trip.passengerUid).child("state").setValue(state.rawValue, andPriority: nil)
    
    if state == .completed {
      FirebaseREF.trips.child(trip.passengerUid).removeAllObservers()
    }
  }
  
  func acceptTrip(trip: Trip) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let passengerUid: String = trip.passengerUid
    let values: [String: Any] = [
      "state": TripState.accepted.rawValue,
      "driverUid": uid
    ]
    
    try await FirebaseREF.trips.child(passengerUid).updateChildValues(values)
  }
  
  func removeAllListener() {
    FirebaseREF.trips.removeAllObservers()
  }
}
