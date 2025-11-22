//
//  ServiceManager.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import SwiftUICore

enum LifeTime {
  case singleton
  case transient
}

struct Registration {
  let lifeTime: LifeTime
  let factory: (Resolver) -> Any
  var cache: Any? = nil
  
  init(lifeTime: LifeTime, factory: @escaping (Resolver) -> Any, cache: Any? = nil) {
    self.lifeTime = lifeTime
    self.factory = factory
    self.cache = cache
  }
}

protocol Resolver {
  func resolve<T>(type: T.Type) -> T
}

class DIContainer: Resolver, ObservableObject {
  static let shared: DIContainer = DIContainer()
  
  private var registrationDict: [ObjectIdentifier: Registration] = [:]
  private var queue: DispatchQueue = DispatchQueue(label: "diContainerQueue", attributes: .concurrent)
  
  private init() {}
  
  @discardableResult
  func register<T>(type: T.Type, lifeTime: LifeTime, factory: @escaping (Resolver) -> T) -> Self {
    let registration = Registration(lifeTime: lifeTime, factory: factory)
    let key = ObjectIdentifier(type)
    
    queue.async(flags: .barrier, execute: { [weak self] in
      guard let self = self else { return }
      self.registrationDict[key] = registration
    })
    
    return self
  }
  
  func resolve<T>(type: T.Type) -> T {
    let key = ObjectIdentifier(type)
    
    var registration: Registration!
    queue.sync {
      registration = registrationDict[key]
    }
    
    if registration == nil {
      fatalError("No registration for type: \(type)")
    }
    
    if registration.lifeTime == .singleton {
      if let cache = registration.cache as? T {
        return cache
      }
      
      let createdItem = registration.factory(self) as! T
      queue.async { [weak self] in
        guard let self = self else { return }
        registration.cache = createdItem
        self.registrationDict[key] = registration
      }
      return createdItem
    } else {
      return registration.factory(self) as! T
    }
  }
}

extension DIContainer {
  static let mock: DIContainer = {
    return DIContainer.shared
  }()
}

struct DIContainerKey: EnvironmentKey {
  static let defaultValue: DIContainer = .shared
}

extension EnvironmentValues {
  var diContainer: DIContainer {
    get { self[DIContainerKey.self] }
    set { self[DIContainerKey.self] = newValue}
  }
}

protocol DIModule {
  @MainActor
  func load(into container: DIContainer)
}

extension DIContainer {
  @MainActor
  func load(modules: [DIModule]) {
    modules.forEach { $0.load(into: self) }
  }
}

//Property Wrapper - pending
