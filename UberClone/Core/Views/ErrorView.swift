//
//  ErrorView.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import SwiftUI

struct ErrorView: View {
  @Binding var error: Error?
  
  private var appError: AppError {
    error.asAppError()
  }
  
  var body: some View {
    VStack(spacing: 16) {
      headingView
      messageView
      okButtonView
    }
    .padding()
    .background(Color.appTheme.cellBackground)
    .cornerRadius(.cell)
    .frame(width: UIScreen.main.bounds.width / 1.2)
  }
}

private extension ErrorView {

  var headingView: some View {
    HStack {
      Image(systemName: "exclamationmark.triangle.fill")
      Text(appError.title)
    }
    .font(.title3)
    .fontWeight(.semibold)
    .foregroundStyle(Color.appTheme.error)
  }
  
  var messageView: some View {
    Text(appError.message)
      .foregroundStyle(.secondaryText)
      .multilineTextAlignment(.center)
  }
  
  var okButtonView: some View {
    Text("OK")
      .destructiveButton()
      .button(.press) {
        dismiss()
      }
  }
}

private extension ErrorView {
  func dismiss() {
    error = nil
  }
}

private struct PreView: View {
  @State var error: Error? = DefaultAppError(title: "Title", message: "Message")
  
  var body: some View {
    ErrorView(error: $error)
      .infinityFrame()
      .background(Color.appTheme.info)
  }
}

#Preview {
  PreView()
}
