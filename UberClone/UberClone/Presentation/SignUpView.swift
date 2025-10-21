// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct SignUpView: View {

  @Environment(\.dismiss) private var dismiss
  @State var email: String = ""
  @State var password: String = ""
  @State var selection = 0

  var body: some View {
    VStack {
      VStack {
        Text("UBER")
          .foregroundStyle(.white)
          .font(.largeTitle)
          .fontWeight(.medium)
        ScrollView {
          formContent
        }
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
    .background(Color(uiColor: AppColors.backgroundColor))
    .navigationBarBackButtonHidden(true)
  }

  var formContent: some View {
    VStack {
      InputTextField(text: $email, placeHolder: "Email", systemImage: "envelope")
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      InputTextField(text: $password, placeHolder: "Full Name", systemImage: "person")
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      InputTextField(text: $password, placeHolder: "Password", systemImage: "lock", isSecure: true)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
      HStack {
        Image(systemName: "person.crop.rectangle")
          .foregroundStyle(.white)
          .padding(.leading, 24)
        Spacer()
      }
      .padding(.bottom, 12)
      CustomSegmentedPicker(selection: $selection, items: ["Rider", "Driver"])
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
      Button {
        //Action
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
    SignUpView()
}
