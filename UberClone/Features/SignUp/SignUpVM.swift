//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import GeoFire

@MainActor
class SignUpVM: ObservableObject, ErrorDisplayable {
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var fullName: String = ""
  @Published var isLoading: Bool = false
  @Published var accountTypeIndex = 0
  @Published var appAlert: AppAlert?
  @Published var error: Error?
  
  private let authService: AuthService
  private let driverService: DriverService
  private let userService: UserService

  init(authService: AuthService = Inject().wrappedValue, driverService: DriverService = Inject().wrappedValue, userService: UserService = Inject().wrappedValue) {
    self.authService = authService
    self.driverService = driverService
    self.userService = userService
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
      defer { isLoading = false }
      let authResult = try await authService.signUp(withEmail: email, password: password)
     
      let uid = authResult.uid

      let values: [String: Any] = [
        "email": email,
        "fullName": fullName,
        "accountType": accountTypeIndex
      ]
      
      if accountTypeIndex == 1 {
        try await driverService.updateDriverLocation(location: location)
      }
      
      try await userService.updateUserData(userId: uid, values: values)
    }
  }

  func showErrorOnUI(message: String) {
    error = DefaultAppError(title: "Sign Up Error", message: message)
  }

  func validateInput() -> Result<Void, SignUpError> {
    var requiredFields: [String] = []
    var invalidFields: [String] = []

    if email.isEmpty {
      requiredFields.append("Email")
    }
    
    if fullName.isEmpty {
      requiredFields.append("Full Name")
    }
   
    if password.isEmpty {
      requiredFields.append("Password")
    }
    
    if !email.isValidEmail {
      invalidFields.append("Email")
    }
    
    if !fullName.isValidUserName {
      invalidFields.append("Full Name")
    }

    if !password.isValidPassword {
      invalidFields.append("Password")
    }

    if !requiredFields.isEmpty {
      return .failure(.missingRequiredFields(requiredFields))
    }
    
    if !invalidFields.isEmpty {
      return .failure(.invalidFields(invalidFields))
    }

    return .success(Void())
  }
}
