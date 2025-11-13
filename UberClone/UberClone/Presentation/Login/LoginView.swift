//
//  LoginView.swift
//  UberClone
//
//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoginView: View {
  
  @StateObject var viewModel: LoginViewVM
  
  init(diContainer: DIContainer) {
    _viewModel = StateObject(wrappedValue: LoginViewVM(diContainer: diContainer))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 48) {
        titleView
        inputFieldsView
        loginButtonView
      }
     
    }
    .padding(.horizontal, 32)
    .padding(.top, 48)
    .padding(.bottom, 4)
    .printFileOnAppear()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
    .navigationDestination(isPresented: $viewModel.showSignUp, destination: {
      SignUpView(diContainer: viewModel.diContainer)
    })
    .showAlert(item: $viewModel.appAlert)
    .showLoading(isLoading: viewModel.isLoading)
    .hideKeyboardOnTap()
    .safeAreaInset(edge: .bottom) {
      signUpButtonView
        .padding(.bottom)
        .padding(.horizontal, 32)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
}

private extension LoginView {
  var titleView: some View {
    Text("UBER")
      .foregroundStyle(Color.appTheme.text)
      .font(.largeTitle)
      .fontWeight(.medium)
  }
  
  var inputFieldsView: some View {
    ScrollView {
      VStack(spacing: 32) {
        AuthTextField(text: $viewModel.email, placeHolder: "Email", systemImage: "envelope")
        AuthTextField(text: $viewModel.password, placeHolder: "Password", systemImage: "lock", isSecure: true)
      }
    }
  }
  
  var loginButtonView: some View {
    Text("Login")
      .primaryButton()
      .button(.press) {
        viewModel.handleLogin()
      }
  }
  
  var signUpButtonView: some View {
    HStack {
      Text("Don't have an account?")
        .foregroundStyle(Color.appTheme.secondaryText)
      Text("Sign Up")
        .fontWeight(.medium)
        .foregroundStyle(Color.appTheme.accent)
    }
    .plainButton()
    .frame(height: 32)
    .button {
      viewModel.showSignUp = true
    }
  }
}

#Preview {
  LoginView(diContainer: DIContainer.mock)
}
