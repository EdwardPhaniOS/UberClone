//
//  AlertView.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

struct AlertView: View {
  @Binding var alert: AppAlert?
  
  var appAlert: AppAlert {
    return alert ?? .empty
  }
  
  var body: some View {
    VStack {
      headingView
      messageView
      actionButtons
    }
    .padding(12)
    .background(Color.appTheme.cellBackground)
    .cornerRadius(.cell)
    .frame(width: UIScreen.main.bounds.width / 1.2)
  }
}

private extension AlertView {
  func dismiss() {
    alert = nil
  }
}

private extension AlertView {
  var headingView: some View {
    Text(appAlert.title)
    .font(.title3)
    .fontWeight(.semibold)
    .foregroundStyle(Color.appTheme.text)
  }
  
  var messageView: some View {
    Text(appAlert.message)
      .foregroundStyle(Color.appTheme.secondaryText)
      .multilineTextAlignment(.center)
  }
  
  var actionButtons: some View {
    HStack(spacing: 5) {
      if let actionButton = appAlert.actionButton {
        cancelButtonView
        Text(actionButton.title)
          .primaryButton()
          .button(.press) {
            actionButton.action()
            dismiss()
          }
      } else {
        okButtonView
      }
    }
  }
  
  var okButtonView: some View {
    Text("OK")
      .primaryButton()
      .button(.press) {
        dismiss()
      }
  }
  
  var cancelButtonView: some View {
    Text("Cancel")
      .plainButton()
      .button(.press) {
        dismiss()
      }
  }
}

fileprivate struct Preview: View {
  @State private var simpleAlert: AppAlert? = .mock1
  @State private var customActionAlert: AppAlert? = .mock2
  
  var body: some View {
    VStack(spacing: 20) {
      AlertView(alert: $simpleAlert)
      AlertView(alert: $customActionAlert)
    }
    .infinityFrame()
    .background(Color.appTheme.info)
  }
}

#Preview {
  Preview()
}
