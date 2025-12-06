//
//  View+keyboardToolbarDoneButton.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func keyboardToolbarDoneButton() -> some View {
    self
      .modifier(KeyboardToolbarDoneButtonViewModifier())
  }
}

struct KeyboardToolbarDoneButtonViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button {
            content.hideKeyboard()
          } label: {
            Text("Done")
              .foregroundStyle(Color.appTheme.accent)
          }
        }
      }
  }
  
}
