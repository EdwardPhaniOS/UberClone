// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct LoadingView: View {
    var body: some View {
      ZStack {
        Color.black.opacity(0.4)
        ProgressView("")
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .foregroundStyle(.white)
          .scaleEffect(1.5)
      }
    }
}

extension View {
  func showLoadingView(isLoading: Bool) -> some View {
    ZStack {
      self.allowsHitTesting(!isLoading)
      if isLoading {
        LoadingView()
      }
    }
  }
}

#Preview {
    LoadingView()
}
