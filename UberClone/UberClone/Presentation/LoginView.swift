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

    var body: some View {
        VStack {
            VStack {
                Text("UBER")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .padding(.top, 48)
                VStack {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundStyle(.white)
                        TextField("Email", text: $email)
                            .foregroundStyle(.white)
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.bottom, 12)
                VStack {
                    HStack {
                        Image(systemName: "lock")
                            .foregroundStyle(.white)
                        TextField("Password", text: $password)
                            .foregroundStyle(.white)
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .padding(.bottom, 12)
                Button {
                    //Action
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .fontWeight(.medium)
                        .font(.title2)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 12)

            }
            Spacer()
            Button {
                //Action
            } label: {
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.white)
                    Text("Sign Up")
                        .fontWeight(.medium)
                }
            }
            .padding(.bottom, 24)
        }
        .background {
            Color.black
        }
        .ignoresSafeArea()

    }
}

#Preview {
    LoginView()
}
