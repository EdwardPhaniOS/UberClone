// Created on 10/28/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import CoreLocation

protocol LocationHandlerDelegate: AnyObject {
  func didUpdateLocations(location: CLLocation)
}

class LocationHandler: NSObject, CLLocationManagerDelegate {

  static let shared = LocationHandler()
  var locationManager: CLLocationManager!
  var location: CLLocation?
  weak var delegate: LocationHandlerDelegate?

  override init() {
    super.init()
    self.locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func enableLocationServices() {
    let status = locationManager?.authorizationStatus

    switch status {
    case .notDetermined:
      // Request only when-in-use unless you need background tracking
      locationManager?.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager?.startUpdatingLocation()
    case .denied, .restricted:
      print("Location access denied or restricted")
    case .none:
      print("Location access not existed")
    @unknown default:
      break
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      manager.startUpdatingLocation()
    case .denied, .restricted:
      print("User denied location access")
    case .notDetermined:
      break
    @unknown default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.location = location
    delegate?.didUpdateLocations(location: location)
  }

}
