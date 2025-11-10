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
  
  let authStore: AuthStore
  
  init(userService: UserService, passengerService: PassengerService, driverService: DriverService, authStore: AuthStore) {
    self.userService = userService
    self.passengerService = passengerService
    self.driverService = driverService
    self.authStore = authStore
  }
 
  init() {
    let userService = DefaultUserService()
    self.userService = userService
    self.passengerService = DefaultPassengerService(userSerivce: userService)
    self.driverService = DefaultDriverService()
    self.authStore = AuthStore()
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
