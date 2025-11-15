//
//  Task+HandlingError.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import Foundation

@MainActor
extension Task where Success == Void, Failure == Error {
  @discardableResult
  init(priority: TaskPriority?, handlingError viewModel: ErrorDisplayable, operation: @escaping () async throws -> Success) {
    self.init(priority: priority) {
      do {
        try await operation()
      } catch {
        viewModel.error = error
      }
    }
  }
}
