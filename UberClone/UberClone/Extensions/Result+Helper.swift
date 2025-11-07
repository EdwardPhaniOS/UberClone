// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

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
