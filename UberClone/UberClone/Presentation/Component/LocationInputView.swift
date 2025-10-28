// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct LocationInputView: View {

  var onBackButtonPressed: (() -> Void)?
  var onSubmit: ((String, String) -> Void)?

  @State var currentLocation: String = ""
  @State var destinationLocation: String = ""
  @Binding var userName: String


  var body: some View {
    ZStack {
      backgroundView
      VStack(spacing: 0) {
        headerView
        locationInputFields
      }
    }
  }

  var backgroundView: some View {
    VStack {
      Rectangle()
        .frame(height: 200)
        .foregroundStyle(.white)
    }
    .shadow(radius: 8)
  }

  var headerView: some View {
    ZStack() {
      HStack {
        Button("", systemImage: "arrow.left") {
          onBackButtonPressed?()
        }
        .foregroundStyle(.black)
        .padding()
        Spacer()
      }
      Text(userName)
        .font(.system(size: 16))
        .foregroundStyle(.secondary)
        .padding(.top, 4)
    }
  }

  var locationInputFields: some View {
    HStack {
      VStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 3)
          .frame(width: 6, height: 6)
          .foregroundStyle(.secondary)
        Rectangle()
          .frame(width: 0.5, height: 24)
          .foregroundStyle(.secondary)
        Rectangle()
          .frame(width: 6, height: 6)
          .foregroundStyle(.secondary)
      }
      .padding(.leading, 16)
      .padding(.trailing, 8)
      VStack {
        ZStack {
          Rectangle()
              .fill(Color.secondary.opacity(0.1))
              .frame(height: 32)
          TextField("Current location", text: $currentLocation)
            .padding(.horizontal, 8)
        }
        ZStack {
          Rectangle()
              .fill(Color.secondary.opacity(0.5))
              .frame(height: 32)
          TextField("Enter a destination..", text: $destinationLocation)
            .padding(.horizontal, 8)
            .submitLabel(.search)
            .onSubmit {
              onSubmit?(currentLocation, destinationLocation)
            }
        }
      }
      .padding(.trailing, 24)
    }
  }

}

#Preview {
  @Previewable @State var userName: String = "Vinh"
  LocationInputView(userName: $userName)
}
