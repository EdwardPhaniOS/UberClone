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
