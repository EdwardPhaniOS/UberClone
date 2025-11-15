//
//  Error+AsAppError.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import Foundation

extension Error? {
  func asAppError() -> AppError {
    guard let appError = self as? AppError else {
      return DefaultAppError.empty
    }
    
    return appError
  }
}
