//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import MapKit

@MainActor
class PickupViewVM: ObservableObject, ErrorDisplayable {

  @Published var cameraPosition: MapCameraPosition
  @Published var countdown: Int = 10
  @Published var error: Error?
  private var timer: Timer?

  private let driverService: DriverService
  
  var pickupCoordinates: CLLocationCoordinate2D
  var trip: Trip

  init(trip: Trip, driverService: DriverService = Inject().wrappedValue) {
    self.trip = trip
    self.driverService = driverService
    self.pickupCoordinates = trip.pickupCoordinates

    cameraPosition = MapCameraPosition.region(
      MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
    )
  }
  
  func countDownToAcceptTrip(completion: @escaping () -> Void) {
    countdown = 10
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      MainActor.assumeIsolated {
        guard let self = self else { return }
        if self.countdown > 1 {
          self.countdown -= 1
        } else {
          self.denyTrip()
          completion()
        }
      }
    }
  }
  
  func denyTrip() {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await driverService.updateTripState(trip: trip, state: .denied)
    }
  }
  
  func cancelCountdown() {
    timer?.invalidate()
    timer = nil
  }
}
