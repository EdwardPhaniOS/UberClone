//
//  LoginView.swift
//  UberClone
//
//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoginView: View {

  @State var email: String = ""
  @State var password: String = ""
  @State var showSignUp: Bool = false

  var body: some View {
    VStack {
      VStack {
        Text("UBER")
          .foregroundStyle(.white)
          .font(.largeTitle)
          .fontWeight(.medium)
        InputTextField(text: $email, placeHolder: "Email", systemImage: "envelope")
          .padding(.horizontal, 24)
          .padding(.bottom, 32)
        InputTextField(text: $password, placeHolder: "Password", systemImage: "lock", isSecure: true)
          .padding(.horizontal, 24)
        Button {
          //Action
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
        showSignUp = true
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

    .background(Color(uiColor: AppColors.backgroundColor))
    .navigationDestination(isPresented: $showSignUp, destination: {
      SignUpView()
    })
  }
}

#Preview {
  LoginView()
}
