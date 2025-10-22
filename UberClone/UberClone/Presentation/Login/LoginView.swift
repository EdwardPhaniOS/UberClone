//
//  LoginView.swift
//  UberClone
//
//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoginView: View {

  @ObservedObject var viewModel: ViewModel

  var body: some View {
    VStack {
      VStack {
        Text("UBER")
          .foregroundStyle(.white)
          .font(.largeTitle)
          .fontWeight(.medium)
        InputTextField(text: $viewModel.email, placeHolder: "Email", systemImage: "envelope")
          .padding(.horizontal, 24)
          .padding(.bottom, 32)
        InputTextField(text: $viewModel.password, placeHolder: "Password", systemImage: "lock", isSecure: true)
          .padding(.horizontal, 24)
        Button {
          viewModel.handleLogin()
        } label: {
          Text("Login")
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
      Spacer()
      Button {
        viewModel.showSignUp = true
      } label: {
        HStack {
          Text("Don't have an account?")
            .foregroundStyle(.white)
          Text("Sign Up")
            .fontWeight(.medium)
            .foregroundStyle(Color(uiColor: AppColors.mainBlueTint))
        }
      }
      .safeAreaPadding(.bottom, 48)
    }
    .printFileOnAppear()
    .background(Color(uiColor: AppColors.backgroundColor))
    .navigationDestination(isPresented: $viewModel.showSignUp, destination: {
      SignUpView(viewModel: .init())
    })
    .alert("", isPresented: $viewModel.showAlert, actions: {
      Button("OK", role: .cancel, action: {})
    }, message: {
      Text(viewModel.alertMessage)
    })
    .showLoadingView(isLoading: viewModel.isLoading)
  }
}

#Preview {
  LoginView(viewModel: .init())
}
