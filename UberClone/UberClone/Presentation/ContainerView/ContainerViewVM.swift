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
class ContainerViewVM: NSObject, ObservableObject, ErrorDisplayable {
  
  @Published var user: User?
  @Published var isLoading: Bool = false
  @Published var showLogin: Bool = false
  @Published var appState = AppState.auth
  @Published var error: Error?
  @Published var appAlert: AppAlert?
  
  var authService: AuthService
  var userService: UserService
  var diContainer: DIContainer
  
  private var cancellables = Set<AnyCancellable>()
  
  //MARK: - Init

  init(diContainer: DIContainer) {
    self.diContainer = diContainer
    self.userService = diContainer.resolve(type: UserService.self)
    self.authService = diContainer.resolve(type: AuthService.self)
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
    }
    showLogin = appState == .auth
  }
  
  func fetchUserData() {
    guard let currentUserId = Auth.auth().currentUser?.uid else { return }
    
    isLoading = true
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      self.user = try await userService.fetchUserData(userId: currentUserId)
    }
  }
  
  func showConfirmSignOut() {
    appAlert = AppAlert(title: "Sign Out?", message: "Are your sure you want to logout?", actionButton: AppAlert.ActionButton.init(title: "Sign Out", action: { [weak self] in
      guard let self = self else { return }
      signOut()
    }))
  }

  private func signOut() {
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
