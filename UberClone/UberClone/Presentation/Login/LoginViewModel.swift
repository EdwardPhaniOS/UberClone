// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation
import FirebaseAuth

extension LoginView {
  class ViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var showSignUp: Bool = false

    func handleLogin() {
      let validateResult = validateInput()
      if let error = validateResult.error as? LoginError {
        showAlertOnUI(message: error.message)
        return
      }

      isLoading = true
      Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
        guard let self = self else { return }
        isLoading = false

        if let error = error {
          showAlertOnUI(message: error.localizedDescription)
          return
        }

        showAlertOnUI(message: "Login successfully")
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

}
