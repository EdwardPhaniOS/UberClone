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

