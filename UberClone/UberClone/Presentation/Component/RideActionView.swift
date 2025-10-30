// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit

struct RideActionView: View {

  var destination: MKPlacemark?

  var onConfirmButtonPressed: (() -> Void)?
  var onCancelButtonPressed: (() -> Void)?

  var body: some View {
    ZStack {
      Rectangle()
        .frame(height: 320)
        .foregroundStyle(Color.white)
        .shadow(radius: 8)
        .offset(y: 28)

      VStack {
        Text(destination?.name ?? "")
          .font(.title2)
        Text(destination?.address ?? "")
          .font(.system(size: 16))
          .foregroundStyle(.secondary)
          .padding(.horizontal, 16)
        Button {
          onCancelButtonPressed?()
        } label: {
          ZStack {
            RoundedRectangle(cornerRadius: 24)
              .frame(width: 48, height: 48)
              .foregroundStyle(Color.black)
            Text("X")
              .foregroundStyle(Color.white)
              .font(.system(size: 24))
          }
        }
        .padding(.top, 8)

        Text("UberX")

        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 0.5)
          .foregroundStyle(Color.gray)
        Button {
          onConfirmButtonPressed?()
        } label: {
          Text("CONFIRM UBERX")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(Color.white)
        }
        .background(Color.black)
        .padding(.horizontal, 16)
        .padding(.top, 16)
      }
    }
  }
}

#Preview {
  RideActionView(destination: nil)
}
