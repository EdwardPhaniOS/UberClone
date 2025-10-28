// Created on 10/28/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import MapKit

extension MKPlacemark {

  var address: String {
    let lines: [String] = [
      subThoroughfare,
      thoroughfare,
      locality,
      administrativeArea,
      postalCode,
    ].compactMap { $0 }

    return lines.joined(separator: ", ")
  }
}
