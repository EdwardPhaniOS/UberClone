//
//  View+ShowLoading.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func showLoading(isLoading: Bool, allowUserInteraction: Bool = false, message: String = "") -> some View {
    self.overlay {
      if isLoading {
        LoadingView(message: message, allowUserInteraction: allowUserInteraction)
      }
    }
  }
}

fileprivate struct Preview: View {
  @State var isLoading = false
  
  var body: some View {
    Text("Show Loading")
      .primaryButton()
      .button {
        isLoading = true
      }
      .padding()
      .showLoading(isLoading: isLoading)
  }
}

#Preview {
  Preview()
}
