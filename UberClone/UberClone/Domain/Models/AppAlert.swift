//
//  AppAlert.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import Foundation

struct AppAlert {
  let title: String
  let message: String
  let actionButton: ActionButton?
  
  init(title: String, message: String, actionButton: ActionButton? = nil) {
    self.title = title
    self.message = message
    self.actionButton = actionButton
  }
}

extension AppAlert {
  struct ActionButton {
    let title: String
    let action: () -> Void
  }
}

extension AppAlert {
  static var empty: Self = .init(title: .empty, message: .empty, actionButton: nil)
  
  static var mock1: Self =  .init(
    title: "Sign Up Error",
    message: "Make sure all fields are completed before proceeding."
  )
  
  static var mock2: Self = .init(
    title: "Sign Out",
    message: "Are you sure you want to sign out?",
    actionButton: .init(title: "Sign Out", action: { })
  )
}
