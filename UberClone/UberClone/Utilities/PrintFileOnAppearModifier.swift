// Created on 10/22/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct PrintFileOnAppearModifier: ViewModifier {

  let fileURL: String

  init(fileURL: String = #file) {
    self.fileURL = fileURL
  }

  func body(content: Content) -> some View {
  #if DEBUG
    content.onAppear {
      let fileName = URL(fileURLWithPath: fileURL).lastPathComponent
      print("File: \(fileName) loaded")
    }
  #endif
  }
}

extension View {
  func printFileOnAppear(fileURL: String = #file) -> some View {
    self.modifier(PrintFileOnAppearModifier(fileURL: fileURL))
  }
}
