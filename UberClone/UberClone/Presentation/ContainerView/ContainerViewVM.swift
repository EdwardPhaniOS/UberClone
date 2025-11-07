//
//  ContainerViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import Firebase

@MainActor
class ContainerViewVM: NSObject, ObservableObject {
  
  @Published var user: User?
  var authStore: AuthStore
  var diContainer: DIContainer
  
  //MARK: - Init

  init(diContainer: DIContainer) {
    self.diContainer = diContainer
    self.authStore = diContainer.authStore
    super.init()
  }
  
  func checkIfUserIsLoggedIn() {
    let isLoggedIn = Auth.auth().currentUser?.uid != nil
    self.authStore.isLoggedIn = isLoggedIn
  }
  
  func fetchUserData() {
    guard let currentUserId = Auth.auth().currentUser?.uid else { return }
    diContainer.userService.fetchUserData(userId: currentUserId) { [weak self] user in
      guard let self = self else { return }
      self.user = user
    }
  }

  func signOut() {
    do {
      try Auth.auth().signOut()
      self.authStore.isLoggedIn = false
    } catch {
      print("DEBUG: Error - \(error.localizedDescription)")
    }
  }
  
  func enableLocationServices() {
    LocationHandler.shared.enableLocationServices()
  }
}
