//  Created by Vinh Phan on 20/10/25.
//

import MapKit

extension MKPlacemark {

  var address: String {
    let lines: [String] = [
      subThoroughfare,
      thoroughfare,
      locality
    ].compactMap { $0 }
    
    return lines.joined(separator: ", ")
  }
}
