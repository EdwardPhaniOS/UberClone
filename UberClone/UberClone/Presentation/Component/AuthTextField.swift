// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct AuthTextField: View {

  @Binding var text: String
  var placeHolder: String = ""
  var systemImage: String
  var isSecure: Bool = false

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      HStack {
        Image(systemName: systemImage)
          .foregroundStyle(.white)
          .frame(width: 24)
        ZStack(alignment: .leading) {
          if text.isEmpty {
            Text(placeHolder)
              .foregroundStyle(.gray)
          }
          if isSecure {
            SecureField(placeHolder, text: $text)
              .foregroundStyle(.white)
          } else {
            TextField(placeHolder, text: $text)
              .foregroundStyle(.white)
          }
        }
      }
      .frame(height: 24)
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(.white)
    }
  }
}

#Preview {
  @Previewable @State var text = ""

  ZStack {
    Rectangle()
      .frame(height: 48)
    AuthTextField(text: $text, placeHolder: "Enter", systemImage: "envelope")
  }
}
