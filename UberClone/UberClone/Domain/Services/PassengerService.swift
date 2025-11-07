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
}

