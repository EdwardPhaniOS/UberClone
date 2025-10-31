// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit

enum RideActionViewState: Equatable {
  case notAvailable
  case requestRide
  case tripAccepted
}

struct RideActionView: View {

  var state: RideActionViewState = .notAvailable
  var destination: MKPlacemark?
  var user: User?

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
        Text(title)
          .font(.title2)
        Text(description)
          .font(.system(size: 16))
          .foregroundStyle(.secondary)
          .padding(.horizontal, 16)
        Button {
          if state == .requestRide {
            onCancelButtonPressed?()
          }
        } label: {
          ZStack {
            RoundedRectangle(cornerRadius: 24)
              .frame(width: 48, height: 48)
              .foregroundStyle(Color.black)
            Text(infoText)
              .foregroundStyle(Color.white)
              .font(.system(size: 24))
          }
        }
        .padding(.top, 8)

        Text(state == .requestRide ? "UberX" : "\(user?.fullName ?? "")")

        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 0.5)
          .foregroundStyle(Color.gray)
        Button {
          onConfirmButtonPressed?()
        } label: {
          Text(buttonTitle)
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

  var infoText: String {
    switch state {
    case .requestRide:
      return "X"
    case .tripAccepted:
      return "\(user?.fullName.first ?? "X")"
    case .notAvailable:
      return ""
    }
  }

  var title: String {
    switch state {
    case .notAvailable, .requestRide:
      return destination?.name ?? ""
    case .tripAccepted:
      return user?.accountType == .driver ? "Driver En Route" : "En Route To Passenger"
    }
  }

  var description: String {
    return destination?.address ?? ""
  }

  var buttonTitle: String {
    switch state {
    case .notAvailable, .requestRide:
      return "CONFIRM UBERX"
    case .tripAccepted:
      return user?.accountType == .driver ?  "CANCEL DRIVE" : "GET DIRECTIONS"
    }
  }
}

#Preview {
  RideActionView(state: .requestRide)
}
