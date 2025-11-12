//
//  ContainerViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation
import Firebase
import Combine

@MainActor
class ContainerViewVM: NSObject, ObservableObject {
  
  @Published var user: User?
  @Published var isLoading: Bool = false
  @Published var showLogin: Bool = false
  @Published var appState = AppState.auth
  
  var authService: AuthService
  var diContainer: DIContainer
  
  private var cancellables = Set<AnyCancellable>()
  
  //MARK: - Init

  init(diContainer: DIContainer) {
    self.diContainer = diContainer
    self.authService = diContainer.authService
    super.init()
  }
  
  func setUpSubcription() {
    authService.authUpdatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self = self else { return }
        updateAppState()
      }
      .store(in: &cancellables)
  }
  
  func updateAppState() {
    let newAppState = authService.getAuthenticatedUser() == nil ? AppState.auth : AppState.app
    if newAppState != appState {
      appState = newAppState
      showLogin = appState == .auth
    }
  }
  
  func fetchUserData() {
    guard let currentUserId = Auth.auth().currentUser?.uid else { return }
    
    isLoading = true
    diContainer.userService.fetchUserData(userId: currentUserId) { [weak self] user in
      guard let self = self else { return }
      self.isLoading = false
      self.user = user
    }
  }

  func signOut() {
    Task {
      do {
        try await authService.signOut()
      } catch {
        print("DEBUG: Error - \(error.localizedDescription)")
      }
    }
  }
  
  func enableLocationServices() {
    LocationHandler.shared.enableLocationServices()
  }
}
