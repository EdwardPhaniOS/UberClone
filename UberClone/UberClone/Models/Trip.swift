// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import CoreLocation

enum TripState: Int {
  case requested
  case accepted
  case inProgress
  case completed
}


struct Trip {
  var pickupCoordinates: CLLocationCoordinate2D!
  var destinationCoordinates: CLLocationCoordinate2D!
  var passengerUid: String!
  var driverUid: String?
  var state: TripState!

  init(passengerUid: String, dict: [String: Any]) {
    self.passengerUid = passengerUid

    if let pickupCoordinates = dict["pickupCoordinates"] as? NSArray {
      guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
      guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
      self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

    if let destinationCoordinates = dict["destinationCoordinates"] as? NSArray {
      guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
      guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
      self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

    self.driverUid = dict["driverUid"] as? String ?? ""

    if let state = dict["state"] as? Int {
      self.state = TripState(rawValue: state)
    }
  }

}

extension Trip {
  static func testData() -> Trip {
    var trip = Trip(passengerUid: UUID().uuidString, dict: [:])
    trip.state = .requested
    trip.destinationCoordinates = CLLocationCoordinate2D(latitude: 15.7769, longitude: 116.7009)
    trip.pickupCoordinates = CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009)
    return trip
  }
}
