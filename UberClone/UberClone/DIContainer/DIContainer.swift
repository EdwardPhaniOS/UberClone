//
//  ServiceManager.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import SwiftUICore

@MainActor
class DIContainer: ObservableObject {
  
  let userService: UserService
  let passengerService: PassengerService
  let driverService: DriverService
  
  let authService: AuthService
  
  init(userService: UserService, passengerService: PassengerService, driverService: DriverService, AuthService: AuthService) {
    self.userService = userService
    self.passengerService = passengerService
    self.driverService = driverService
    self.authService = AuthService
  }
 
  init() {
    let userService = DefaultUserService()
    self.userService = userService
    self.passengerService = DefaultPassengerService(userSerivce: userService)
    self.driverService = DefaultDriverService()
    self.authService = DefaultAuthService()
  }
}

extension DIContainer {
  static let mock: DIContainer = DIContainer()
}

private struct DIContainerKey: @preconcurrency EnvironmentKey {

  @MainActor
  static let defaultValue: DIContainer = DIContainer()
}

extension EnvironmentValues {
  var diContainer: DIContainer {
    get {self[DIContainerKey.self]}
    set {self[DIContainerKey.self] = newValue }
  }
}
