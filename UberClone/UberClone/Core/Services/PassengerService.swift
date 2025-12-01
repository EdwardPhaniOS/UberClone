//
//  PassengerService.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Firebase
import FirebaseAuth
import GeoFire
import Combine

protocol PassengerService {
  @discardableResult
  func fetchDrivers(location: CLLocation) -> AnyPublisher<User, Error>
  
  func uploadTrip(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) async throws
  
  @discardableResult
  func observeCurrentTrip() -> AnyPublisher<Trip, Error>
  
  func deleteTrip() async throws
  
  func saveLocation(type: LocationType, location: String) async throws
  
  func removeAllListeners()
}

class DefaultPassengerService: PassengerService {
  private let userSerivce: UserService
  
  init(userSerivce: UserService) {
    self.userSerivce = userSerivce
  }
  
  @discardableResult
  func fetchDrivers(location: CLLocation) -> AnyPublisher<User, Error> {
    let publisher = PassthroughSubject<User, Error>()
    
    let geofire = GeoFire(firebaseRef: FirebaseREF.driverLocations)
    FirebaseREF.driverLocations.observe(.value) { [weak self] snapshot in
      guard let self = self else { return }
      
      geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { driverId, driverLocation in
        Task {
          do {
            let driver = try await self.userSerivce.fetchUserData(userId: driverId)
            driver.location = driverLocation
            publisher.send(driver)
          } catch {
            publisher.send(completion: .failure(error))
          }
        }
      })
    }
    
    return publisher.eraseToAnyPublisher()
  }
  
  func uploadTrip(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
    let destinationArray = [destinationCoordinate.latitude, destinationCoordinate.longitude]

    let values: [String: Any] = [
      "pickupCoordinates": pickupArray,
      "destinationCoordinates": destinationArray,
      "state": TripState.requested.rawValue
    ]

    try await FirebaseREF.trips.child(uid).updateChildValues(values)
  }
  
  func observeCurrentTrip() -> AnyPublisher<Trip, Error> {
    let publisher = PassthroughSubject<Trip, Error>()
    
    guard let uid = Auth.auth().currentUser?.uid else { return publisher.eraseToAnyPublisher() }

    FirebaseREF.trips.child(uid).observe(.value) { snapshot in
      guard let dict = snapshot.value as? [String: Any] else { return }
      let uid = snapshot.key
      let trip = Trip(passengerUid: uid, dict: dict)
      publisher.send(trip)
    }
    
    return publisher.eraseToAnyPublisher()
  }
  
  func deleteTrip() async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    try await FirebaseREF.trips.child(uid).removeValue()
  }
  
  func saveLocation(type: LocationType, location: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let key: String = type == .home ? "homeLocation" : "workLocation"
    try await FirebaseREF.users.child(uid).child(key).setValue(location)
  }
  
  func removeAllListeners() {
    FirebaseREF.driverLocations.removeAllObservers()
  }
  
}
