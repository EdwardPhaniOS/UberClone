//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import FirebaseAuth

@MainActor
class LoginViewVM: ObservableObject, ErrorDisplayable {
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var isLoading: Bool = false
  @Published var showSignUp: Bool = false
  @Published var appAlert: AppAlert?
  @Published var error: Error?
  
  private let authService: AuthService

  init(authService: AuthService = Inject().wrappedValue) {
    self.authService = authService
  }

  func handleLogin() {
    let validateResult = validateInput()
    if let error = validateResult.error as? LoginError {
      showErrorOnUI(message: error.message)
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

  func showErrorOnUI(message: String) {
    error = DefaultAppError(title: "Sign In Error", message: message)
  }
}
