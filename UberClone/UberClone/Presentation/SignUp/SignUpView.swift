// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct SignUpView: View {

  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: SignUpVM

  var body: some View {
    VStack {
      Text("UBER")
        .foregroundStyle(.white)
        .font(.largeTitle)
        .fontWeight(.medium)
      ScrollView {
        formContent
      }
      Spacer()
      Button {
        dismiss()
      } label: {
        HStack {
          Text("Already have an account?")
            .foregroundStyle(.white)
          Text("Log In")
            .fontWeight(.medium)
            .foregroundStyle(Color(uiColor: AppColors.mainBlueTint))
        }
      }
      .safeAreaPadding(.bottom, 48)
    }
    .alert("", isPresented: $viewModel.showAlert, actions: {
      Button("OK", role: .cancel, action: {})
    }, message: {
      Text(viewModel.alertMessage)
    })
    .showLoadingView(isLoading: viewModel.isLoading)
    .background(Color(uiColor: AppColors.backgroundColor))
    .navigationBarBackButtonHidden(true)
    .printFileOnAppear()
  }

  var formContent: some View {
    VStack {
      AuthTextField(text: $viewModel.email, placeHolder: "Email", systemImage: "envelope")
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      AuthTextField(text: $viewModel.fullName, placeHolder: "Full Name", systemImage: "person")
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      AuthTextField(text: $viewModel.password, placeHolder: "Password", systemImage: "lock", isSecure: true)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      HStack {
        Image(systemName: "person.crop.rectangle")
          .foregroundStyle(.white)
          .padding(.leading, 24)
        Spacer()
      }
      .padding(.bottom, 12)
      CustomSegmentedPicker(selection: $viewModel.accountTypeIndex, items: ["Rider", "Driver"])
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
      Button {
        viewModel.handleSignUp()
      } label: {
        Text("Sign Up")
          .frame(maxWidth: .infinity)
          .padding()
          .fontWeight(.medium)
          .font(.title2)
          .background(Color(uiColor: AppColors.mainBlueTint))
          .foregroundStyle(.white)
          .cornerRadius(8)
      }
      .padding(.top, 32)
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  @Previewable @State var authViewModel = AuthViewModel()

  SignUpView(viewModel: .init(authViewModel: authViewModel))
    .environmentObject(authViewModel)
}
