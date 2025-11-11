// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit

@MainActor
class PickupViewVM: ObservableObject {

  @Published var cameraPosition: MapCameraPosition
  @Published var countdown: Int = 0
  private var timer: Timer?

  var diContainer: DIContainer
  var pickupCoordinates: CLLocationCoordinate2D
  var trip: Trip

  init(diContainer: DIContainer, trip: Trip) {
    self.diContainer = diContainer
    self.trip = trip
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
          self.timer?.invalidate()
          self.timer = nil
          self.denyTrip()
          completion()
        }
      }
    }
  }
  
  func denyTrip() {
    diContainer.driverService.updateTripState(trip: trip, state: .denied) { error, _ in
      if let error = error {
        print("DEBUG - error: \(error)")
      }
    }
  }
}
