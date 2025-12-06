//
//  ServiceModule.swift
//  UberClone
//
//  Created by Vinh Phan on 22/11/25.
//

import Foundation

@MainActor
struct ServiceModule: DIModule {
  func load(into container: DIContainer) {
    container.register(type: DriverService.self, lifeTime: .singleton) { _ in
      return DefaultDriverService()
    }
    
    container.register(type: UserService.self, lifeTime: .singleton) { _ in
      return DefaultUserService()
    }
    
    container.register(type: PassengerService.self, lifeTime: .singleton) { resolver in
      let userService = resolver.resolve(type: UserService.self)
      return DefaultPassengerService(userSerivce: userService)
    }
    
    container.register(type: AuthService.self, lifeTime: .singleton) { _ in
      return DefaultAuthService()
    }
  }
}
