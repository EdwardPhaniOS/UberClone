//  Created by Vinh Phan on 20/10/25.
//

import CoreLocation
import Combine

class LocationHandler: NSObject, CLLocationManagerDelegate {

  static let shared = LocationHandler()
  var locationManager: CLLocationManager!
  
  @Published var location: CLLocation?
  @Published var enterRegion: CLRegion?

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
  
  func uploadLocationPublisher() -> AnyPublisher<CLLocation?, Never> {
    $location.eraseToAnyPublisher()
  }
  
  func enterRegionPublisher() -> AnyPublisher<CLRegion?, Never> {
    $enterRegion.eraseToAnyPublisher()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.location = location
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    self.enterRegion = region
  }

}
