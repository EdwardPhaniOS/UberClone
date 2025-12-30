//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct SignUpView: View {

  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: SignUpVM
  
  init() {
    _viewModel = StateObject(wrappedValue: SignUpVM())
  }

  var body: some View {
    ViewThatFits {
      contentView

      ScrollView(content: {
        contentView
      })
    }
    .padding(.horizontal, 32)
    .padding(.top, 48)
    .padding(.bottom, 4)
    .infinityFrame()
    .showAlert(item: $viewModel.appAlert)
    .showError(item: $viewModel.error)
    .showLoading(isLoading: viewModel.isLoading)
    .background(Color.appTheme.viewBackground)
    .navigationBarBackButtonHidden(true)
    .printFileOnAppear()
    .hideKeyboardOnTap()
  }  
}

private extension SignUpView {
  var contentView: some View {
    VStack(spacing: 48) {
      titleView
      inputFieldsView
      VStack {
        signUpButtonView
        loginButtonView
      }
      Spacer()
    }
  }

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
        .autocorrectionDisabled()
      TextField("Full Name", text: $viewModel.fullName)
        .textFieldWithUnderline(sfSymbol: "person")
      SecureField("Password", text: $viewModel.password)
        .textFieldWithUnderline(sfSymbol: "lock")
        .autocorrectionDisabled()
      VStack {
        HStack {
          Image(systemName: "person.crop.rectangle")
            .foregroundStyle(Color.appTheme.divider)
          Spacer()
        }
        CustomSegmentedPicker(selection: $viewModel.accountTypeIndex, items: ["Passenger", "Driver"])
      }
      
    }
  }
  
  var signUpButtonView: some View {
    Text("Sign Up")
      .primaryButton()
      .button(.press) {
        viewModel.handleSignUp()
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
  SignUpView()
}
