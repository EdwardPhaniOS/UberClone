//
//  View+showAlert.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func showAlert(item: Binding<AppAlert?>) -> some View {
    showModal(isPresenting: item) { _ in
      AlertView(alert: item)
        .transition(
          .move(edge: .bottom)
          .combined(with: .blurReplace)
        )
    }
  }
}

private struct Preview: View {
  @State var appAlert: AppAlert?
  
  var body: some View {
    Text("Show Alert")
      .primaryButton()
      .button {
        appAlert = .mock2
      }
      .padding()
      .showAlert(item: $appAlert)
  }
}

#Preview {
  Preview()
}
