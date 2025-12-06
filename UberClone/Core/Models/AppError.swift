//
//  AppError.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import Foundation

protocol AppError: LocalizedError {
  var title: String { get }
  var message: String { get }
}

struct DefaultAppError: AppError {
  var title: String
  var message: String
  
  init(title: String, message: String) {
    self.title = title
    self.message = message
  }
  
  static var empty: AppError = DefaultAppError(title: .empty, message: .empty)
  static var mock: AppError = DefaultAppError(title: "Title", message: "Message")
}

