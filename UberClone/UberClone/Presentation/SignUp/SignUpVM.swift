// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import GeoFire

@MainActor
class SignUpVM: ObservableObject, ErrorDisplayable {
  let authService: AuthService
  let diContainer: DIContainer
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var fullName: String = ""
  @Published var isLoading: Bool = false
  @Published var accountTypeIndex = 0
  @Published var appAlert: AppAlert?
  @Published var error: Error?

  init(diContainer: DIContainer) {
    self.diContainer = diContainer
    self.authService = diContainer.authService
  }

  func handleSignUp() {
    let validateResult = validateInput()
    if let error = validateResult.error as? SignUpError {
      showErrorOnUI(message: error.message)
      return
    }
    
    guard let location = LocationHandler.shared.location else {
      showErrorOnUI(message: SignUpError.missingCurrentLocation.message)
      return
    }

    isLoading = true
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      
      let authResult = try await authService.signUp(withEmail: email, password: password)
      defer { isLoading = false }
      
      let uid = authResult.uid

      let values: [String: Any] = [
        "email": email,
        "fullName": fullName,
        "accountType": accountTypeIndex
      ]
      
      if accountTypeIndex == 1 {
        try await diContainer.driverService.updateDriverLocation(location: location)
      }
      
      try await diContainer.userService.updateUserData(userId: uid, values: values)
    }
  }

  func showErrorOnUI(message: String) {
    error = DefaultAppError(title: "Sign Up Error", message: message)
  }

  func validateInput() -> Result<Void, SignUpError> {
    var requiredFields: [String] = []

    if email.isEmpty {
      requiredFields.append("Email")
    }

    if fullName.isEmpty {
      requiredFields.append("Full Name")
    }

    if password.isEmpty {
      requiredFields.append("Password")
    }

    if !requiredFields.isEmpty {
      return .failure(.missingRequiredFields(requiredFields))
    }

    return .success(Void())
  }
}
