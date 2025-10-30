// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit

extension PickupView {
  class ViewModel: ObservableObject {

    @Published var cameraPosition: MapCameraPosition

    var pickupCoordinates: CLLocationCoordinate2D
    var trip: Trip

    init(trip: Trip) {
      self.trip = trip
      self.pickupCoordinates = trip.pickupCoordinates

      cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude),
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      )
    }
  }

}
