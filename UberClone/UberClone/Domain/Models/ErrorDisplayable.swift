//
//  ErrorDisplayable.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import Foundation

@MainActor
protocol ErrorDisplayable: AnyObject {
  var error: Error? { get set }
}
