//
//  ViewExt.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func primaryButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.accentContrastText)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.appTheme.accent)
      .cornerRadius(.button)
      .shadow(.regular)
  }
  
  func destructiveButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.accentContrastText)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.appTheme.destructive)
      .cornerRadius(.button)
      .shadow(.regular)
  }
  
  func plainButton() -> some View {
    self
      .font(.headline)
      .foregroundStyle(Color.appTheme.text)
      .frame(maxWidth: .infinity)
      .padding()
  }
}

fileprivate struct Preview: View {
  var body: some View {
    VStack(spacing: 20) {
      Text("Get Started")
        .primaryButton()
        .button(.plain, action: {})
      
      Text("Sign Out")
        .destructiveButton()
        .button(.press, action: {})
      
      Text("Cancel")
        .plainButton()
        .button(.press, action: {})
    }
    .padding()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
  }
}

#Preview {
  Preview()
}
