//  Created by Vinh Phan on 20/10/25.
//

import Foundation

extension Result {
  var isSuccess: Bool {
    if case .success = self {
      return true
    }
    return false
  }

  var error: Error? {
    if case .failure(let err) = self {
      return err
    }
    return nil
  }
}
