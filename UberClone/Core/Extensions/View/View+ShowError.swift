//
//  View+ShowError.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import SwiftUI

extension View {
  func showError(item: Binding<Error?>) -> some View {
    showModal(isPresenting: item) { _ in
      ErrorView(error: item)
        .transition(
          .move(edge: .bottom)
          .combined(with: .blurReplace)
        )
    }
  }
}

private struct PreviewView: View {
  @State var error: Error?
  
  var body: some View {
    Text("Show Error")
      .primaryButton()
      .button(.press) {
        showError()
      }
      .padding()
      .infinityFrame()
      .background(Color.appTheme.viewBackground)
      .showError(item: $error)
  }
  
  func showError() {
    error = DefaultAppError.mock
  }
}

#Preview {
  PreviewView()
}
