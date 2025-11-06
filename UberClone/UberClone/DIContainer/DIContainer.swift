//
//  ServiceManager.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import SwiftUICore

struct DIContainer {
  
  let userService: UserService
  let passengerService: PassengerService
  let driverService: DriverService
  
  static let preview: DIContainer = DIContainer()
  
  init(userService: UserService, passengerService: PassengerService, driverService: DriverService) {
    self.userService = userService
    self.passengerService = passengerService
    self.driverService = driverService
  }
 
  init() {
    let userService = DefaultUserService()
    self.userService = userService
    self.passengerService = DefaultPassengerService(userSerivce: userService)
    self.driverService = DefaultDriverService()
  }
  
}

private struct DIContainerKey: EnvironmentKey {
  static let defaultValue: DIContainer = DIContainer()
}

extension EnvironmentValues {
  var diContainer: DIContainer {
    get {self[DIContainerKey.self]}
    set {self[DIContainerKey.self] = newValue }
  }
}
