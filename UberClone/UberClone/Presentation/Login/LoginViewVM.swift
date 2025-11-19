// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth

@MainActor
class LoginViewVM: ObservableObject, ErrorDisplayable {
  var authService: AuthService
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var isLoading: Bool = false
  @Published var showSignUp: Bool = false
  @Published var appAlert: AppAlert?
  @Published var error: Error?
  var diContainer: DIContainer

  init(diContainer: DIContainer) {
    self.diContainer = diContainer
    self.authService = diContainer.authService
  }

  func handleLogin() {
    let validateResult = validateInput()
    if let error = validateResult.error as? LoginError {
      showAlertOnUI(message: error.message)
      return
    }
    
    isLoading = true
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer {
        self.isLoading = false
      }
      
      try await authService.signIn(withEmail: email, password: password)
    }
  }

  func validateInput() -> Result<Void, LoginError> {
    var requiredFields: [String] = []

    if email.isEmpty {
      requiredFields.append("Email")
    }

    if password.isEmpty {
      requiredFields.append("Password")
    }

    if !requiredFields.isEmpty {
      return .failure(.missingRequiredFields(requiredFields))
    }

    return .success(Void())
  }

  func showAlertOnUI(message: String) {
    appAlert = AppAlert(title: "Sign In Error", message: message)
  }
}
