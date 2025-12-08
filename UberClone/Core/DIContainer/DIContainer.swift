import Foundation
import SwiftUI

// MARK: - Core Types

enum Lifetime {
  case singleton
  case transient
}

protocol Resolver {
  func resolve<T>() -> T
  func resolve<T>(type: T.Type) -> T
}

extension Resolver {
  func resolve<T>() -> T {
    return resolve(type: T.self)
  }
}

// MARK: - DIContainer

final class DIContainer: Resolver {

  static let shared = DIContainer()

  private let syncQueue = DispatchQueue(label: "com.company.DIContainer.syncQueue", attributes: .concurrent)

  private var registrations: [ObjectIdentifier: Registration] = [:]
  private init() {}

  // MARK: - Registration

  @discardableResult
  func register<T>(
    type: T.Type = T.self,
    lifetime: Lifetime = .transient,
    factory: @escaping (Resolver) -> T
  ) -> Self {
    syncQueue.sync(flags: .barrier) {
      let registration = Registration(lifetime: lifetime, factory: factory)
      registrations[ObjectIdentifier(type)] = registration
    }
    return self
  }

  // MARK: - Resolution
  
  func resolve<T>(type: T.Type = T.self) -> T {
    return syncQueue.sync {
      let key = ObjectIdentifier(type)

      guard let registration = self.registrations[key] else {
        fatalError("No registration found for type \(String(describing: type))")
      }

      switch registration.lifetime {
      case .transient:
        guard let instance = registration.factory(self) as? T else {
          fatalError("Factory for \(String(describing: type)) returned incorrect type.")
        }
        return instance

      case .singleton:
        if let cachedInstance = registration.cachedInstance {
          guard let instance = cachedInstance as? T else {
            fatalError("Cached instance for \(String(describing: type)) has incorrect type.")
          }
          return instance
        }

        let instance = registration.factory(self)
        registration.cachedInstance = instance

        guard let finalInstance = instance as? T else {
          fatalError("Factory for \(String(describing: type)) returned incorrect type.")
        }
        return finalInstance
      }
    }
  }
}

// MARK: - Registration Details

private extension DIContainer {
  class Registration {
    let lifetime: Lifetime
    let factory: (Resolver) -> Any
    var cachedInstance: Any?

    init(lifetime: Lifetime, factory: @escaping (Resolver) -> Any) {
      self.lifetime = lifetime
      self.factory = factory
    }
  }
}

// MARK: - SwiftUI Environment Integration

struct DIContainerKey: EnvironmentKey {
  static let defaultValue: DIContainer = .shared
}

extension EnvironmentValues {
  var diContainer: DIContainer {
    get { self[DIContainerKey.self] }
    set { self[DIContainerKey.self] = newValue }
  }
}

// MARK: - Module Loading

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

// MARK: - Inject Property Wrapper
@propertyWrapper
struct Inject<T> {
  let wrappedValue: T

  init(resolver: Resolver = DIContainer.shared) {
    self.wrappedValue = resolver.resolve(type: T.self)
  }
}
