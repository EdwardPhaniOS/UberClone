//  Created by Vinh Phan on 20/10/25.
//

import Foundation
import Combine
import Firebase

@MainActor
protocol AuthService {
  var authUpdate: Date { get }
  var authUpdatePublisher: AnyPublisher<Date, Never> { get }
  
  func getAuthenticatedUser() -> AuthData?
  
  @discardableResult
  func signIn(withEmail: String, password: String) async throws -> AuthData
  
  @discardableResult
  func signUp(withEmail: String, password: String) async throws -> AuthData
  
  func signOut() async throws
}

@MainActor
class DefaultAuthService: ObservableObject, AuthService {
  
  @Published var authUpdate: Date = .init()
  
  var authUpdatePublisher: AnyPublisher<Date, Never> {
    $authUpdate.eraseToAnyPublisher()
  }
  
  @discardableResult
  func signIn(withEmail: String, password: String) async throws -> AuthData {
    let authResult = try await Auth.auth().signIn(withEmail: withEmail, password: password)
    authUpdate = .now
    return AuthData(uid: authResult.user.uid, email: authResult.user.email)
  }
  
  func signUp(withEmail: String, password: String) async throws -> AuthData {
    let authResult = try await Auth.auth().createUser(withEmail: withEmail, password: password)
    authUpdate = .now
    return AuthData(uid: authResult.user.uid, email: authResult.user.email)
  }
  
  func signOut() async throws {
    try Auth.auth().signOut()
    authUpdate = .now
  }
  
  func getAuthenticatedUser() -> AuthData? {
    guard let currentUser = Auth.auth().currentUser else { return nil }
    return AuthData(uid: currentUser.uid, email: currentUser.email)
  }

}
