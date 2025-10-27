// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct LocationInputActivationView: View {

  var body: some View {
    HStack() {
      Rectangle()
        .frame(width: 8, height: 8)
        .foregroundStyle(.black)
        .padding(.leading, 12)
      Text("Where to?")
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
    .background(Color.white)
    .shadow(radius: 8)
  }
}

#Preview {
  LocationInputActivationView()
}
