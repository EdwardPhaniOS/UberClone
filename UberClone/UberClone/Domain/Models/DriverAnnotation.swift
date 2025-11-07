// Created on 10/28/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation, Identifiable {
  var id: UUID = UUID()
  var uuid: String
  var coordinate: CLLocationCoordinate2D

  init(uuid: String, coordinate: CLLocationCoordinate2D) {
    self.uuid = uuid
    self.coordinate = coordinate
  }
}

extension DriverAnnotation {
  static func testData() -> [DriverAnnotation] {
      let center = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.00902)
      return [
        DriverAnnotation(uuid: UUID().uuidString, coordinate: center),
        DriverAnnotation(uuid: UUID().uuidString, coordinate: CLLocationCoordinate2D(latitude: 37.3333, longitude: -122.0070)),
        DriverAnnotation(uuid: UUID().uuidString, coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0054)),
        DriverAnnotation(uuid: UUID().uuidString, coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0150))
      ]
    }

}
