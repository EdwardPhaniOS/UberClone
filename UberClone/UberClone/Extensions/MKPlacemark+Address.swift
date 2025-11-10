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
    
    var seen: Set<String> = []
    var uniqueLines: [String] = []
    for line in lines {
      if seen.contains(line) {
        continue
      }
      
      seen.insert(line)
      uniqueLines.append(line)
    }

    return uniqueLines.joined(separator: ", ")
  }
}
