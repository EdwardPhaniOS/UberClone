//
//  LoginView.swift
//  UberClone
//
//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoginView: View {
  
  @StateObject var viewModel: LoginViewVM
  
  init() {
    _viewModel = StateObject(wrappedValue: LoginViewVM())
  }

  var body: some View {
    ScrollView(content: {
      VStack(spacing: 48) {
        titleView
        inputFieldsView
        VStack {
          loginButtonView
          signUpButtonView
        }
        Spacer()
      }
    })
    .infinityFrame()
    .padding(.horizontal, 32)
    .padding(.top, 48)
    .padding(.bottom, 4)
    .printFileOnAppear()
    .background(Color.appTheme.viewBackground)
    .navigationDestination(isPresented: $viewModel.showSignUp, destination: {
      SignUpView()
    })
    .showAlert(item: $viewModel.appAlert)
    .showError(item: $viewModel.error)
    .showLoading(isLoading: viewModel.isLoading)
    .hideKeyboardOnTap()
    .keyboardToolbarDoneButton()
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
    VStack(spacing: 32) {
      TextField("Email", text: $viewModel.email)
        .textFieldWithUnderline(sfSymbol: "envelope")
      SecureField("Password", text: $viewModel.password)
        .textFieldWithUnderline(sfSymbol: "lock")
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
  LoginView()
}
