// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth

@MainActor
class LoginViewVM: ObservableObject {
  var authService: AuthService
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var alertMessage: String = ""
  @Published var showAlert: Bool = false
  @Published var isLoading: Bool = false
  @Published var showSignUp: Bool = false
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

    Task {
      do {
        isLoading = true
        try await authService.signIn(withEmail: email, password: password)
        isLoading = false
      } catch {
        showAlertOnUI(message: error.localizedDescription)
        isLoading = false
      }
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
    showAlert = true
    alertMessage = message
  }
}
