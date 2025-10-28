// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import GeoFire

extension SignUpView {
  class ViewModel: ObservableObject {
    let authViewModel: AuthViewModel
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var fullName: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var accountTypeIndex = 0

    init(authViewModel: AuthViewModel) {
      self.authViewModel = authViewModel
    }

    func handleSignUp() {
      let validateResult = validateInput()
      if let error = validateResult.error as? SignUpError {
        showAlertOnUI(message: error.message)
        return
      }

      isLoading = true
      Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
        guard let self = self else { return }
        isLoading = false

        if let error = error {
          self.showAlertOnUI(message: "Failed to register user with error: \(error.localizedDescription)")
          return
        }

        guard let uid = result?.user.uid else { return }

        let values: [String: Any] = [
          "email": email,
          "fullName": fullName,
          "accountType": accountTypeIndex
        ]

        if accountTypeIndex == 1 {
          self.uploadDriverLocationAndData(values: values, userId: uid)
        } else {
          self.uploadUserDataAndShowHomeView(values: values, userId: uid)
        }
      }
    }

    func uploadDriverLocationAndData(values: [String: Any], userId: String) {
      guard let location = LocationHandler.shared.location else {
        showAlertOnUI(message: SignUpError.missingCurrentLocation.message)
        return
      }

      let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
      geofire.setLocation(location, forKey: userId) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          showAlertOnUI(message: error.localizedDescription)
        }
        self.uploadUserDataAndShowHomeView(values: values, userId: userId)
      }
    }

    func uploadUserDataAndShowHomeView(values: [String: Any], userId: String)  {
      REF_USERS.child(userId).updateChildValues(values) { error, ref in
        DispatchQueue.main.async {
          self.authViewModel.isLoggedIn = true
        }
      }
    }

    func showAlertOnUI(message: String) {
      showAlert = true
      alertMessage = message
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
}
