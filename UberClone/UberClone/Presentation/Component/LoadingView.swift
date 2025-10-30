// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct LoadingView: View {
  var message: String = ""

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
      ProgressView(message)
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .foregroundStyle(.white)
        .scaleEffect(1.5)
        .font(.system(size: 14))
    }
    .ignoresSafeArea()
  }
}

extension View {
  func showLoadingView(isLoading: Bool, message: String = "") -> some View {
    ZStack {
      self.allowsHitTesting(!isLoading)
      if isLoading {
        LoadingView(message: message)
      }
    }
  }
}

#Preview {
  LoadingView(message: "Loading...")
}
