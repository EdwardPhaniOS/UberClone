//
//  AuthError.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import Foundation
import FirebaseAuth

enum AuthError {
  case invalidCredentials
  case missingFields
  case userNotFound
  case emailAlreadyInUse
  case weakPassword
  case tooManyRequests
  case networkError
  case unknown(Error)
}

extension AuthError: AppError {
  var title: String {
    "Authentication Error"
  }
  
  var message: String {
    return switch self {
    case .invalidCredentials:
      "Invalid email or password. Please try again."
    case .missingFields:
      "All fields must be filled out."
    case .userNotFound:
      "No account found for this email."
    case .emailAlreadyInUse:
      "This email is already in use."
    case .weakPassword:
      "Your password is too weak. Try a stronger one."
    case .tooManyRequests:
      "You've made too many attempts. Please wait and try again later."
    case .networkError:
      "A network error occurred. Check your connection and try again."
    case .unknown(let error):
      error.localizedDescription
    }
  }
  
  static func firebaseAuthError(error: NSError) -> AppError {
    let authErrorCode = AuthErrorCode(_nsError: error)
    
    return switch authErrorCode {
    case AuthErrorCode.wrongPassword, AuthErrorCode.invalidEmail:
      AuthError.invalidCredentials
    case AuthErrorCode.userNotFound:
      AuthError.userNotFound
    case AuthErrorCode.emailAlreadyInUse:
      AuthError.emailAlreadyInUse
    case AuthErrorCode.weakPassword:
      AuthError.weakPassword
    case AuthErrorCode.tooManyRequests:
      AuthError.tooManyRequests
    case AuthErrorCode.networkError:
      AuthError.networkError
    default:
      AuthError.unknown(error)
    }
  }
}
