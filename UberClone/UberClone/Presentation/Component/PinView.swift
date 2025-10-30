// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct PinView: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 2)
        .foregroundStyle(Color.orange)
        .frame(width: 4, height: 4)
      Image(systemName: "mappin.circle.fill")
        .foregroundStyle(.orange)
        .font(.system(size: 28))
        .offset(y: -20)
      Image(systemName: "arrowtriangle.down.fill")
        .foregroundStyle(.orange)
        .font(.system(size: 8))
        .offset(y: -5)
    }
  }
}

#Preview {
  PinView()
}
