// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct SignUpView: View {

  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: SignUpVM
  
  init(diContainer: DIContainer) {
    _viewModel = StateObject(wrappedValue: SignUpVM(diContainer: diContainer))
  }

  var body: some View {
    ScrollView(content: {
      VStack(spacing: 48) {
        titleView
        inputFieldsView
        signUpButtonView
      }
    })
    .padding(.horizontal, 32)
    .padding(.top, 48)
    .padding(.bottom, 4)
    .infinityFrame()
    .showAlert(item: $viewModel.appAlert)
    .showLoading(isLoading: viewModel.isLoading)
    .background(Color.appTheme.viewBackground)
    .navigationBarBackButtonHidden(true)
    .printFileOnAppear()
    .hideKeyboardOnTap()
    .safeAreaInset(edge: .bottom) {
      loginButtonView
        .padding(.bottom)
        .padding(.horizontal, 32)
    }
    .ignoresSafeArea(.keyboard)
  }

  
}

private extension SignUpView {
  var titleView: some View {
    Text("UBER")
      .foregroundStyle(Color.appTheme.text)
      .font(.largeTitle)
      .fontWeight(.medium)
  }
  
  var inputFieldsView: some View {
    VStack(spacing: 32) {
      AuthTextField(text: $viewModel.email, placeHolder: "Email", systemImage: "envelope")
      AuthTextField(text: $viewModel.fullName, placeHolder: "Full Name", systemImage: "person")
      AuthTextField(text: $viewModel.password, placeHolder: "Password", systemImage: "lock", isSecure: true)
      VStack {
        HStack {
          Image(systemName: "person.crop.rectangle")
            .foregroundStyle(Color.appTheme.divider)
          Spacer()
        }
        CustomSegmentedPicker(selection: $viewModel.accountTypeIndex, items: ["Rider", "Driver"])
      }
      
    }
  }
  
  var signUpButtonView: some View {
    Button {
      viewModel.handleSignUp()
    } label: {
      Text("Sign Up")
        .frame(maxWidth: .infinity)
        .padding()
        .fontWeight(.medium)
        .font(.title2)
        .background(Color.appTheme.accent)
        .foregroundStyle(.white)
        .cornerRadius(8)
    }
  }
  
  var loginButtonView: some View {
    HStack {
      Text("Already have an account?")
        .foregroundStyle(Color.appTheme.secondaryText)
      Text("Log In")
        .fontWeight(.medium)
        .foregroundStyle(Color.appTheme.accent)
    }
    .plainButton()
    .frame(height: 32)
    .button {
      dismiss()
    }
  }
}

#Preview {
  SignUpView(diContainer: DIContainer.mock)
}
