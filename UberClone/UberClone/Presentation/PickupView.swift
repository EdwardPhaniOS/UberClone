// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit

struct PickupView: View {
  @ObservedObject var viewModel: ViewModel

  var onCloseButtonPressed: (() -> Void)?
  var onAcceptButtonPressed: (() -> Void)?

  var body: some View {
    VStack {
      HStack{
        Button("", systemImage: "xmark") {
          onCloseButtonPressed?()
        }
        .font(.system(size: 18, weight: .bold))
        .foregroundStyle(.white)
        .padding(.top, 4)
        .padding(.leading, 16)
        Spacer()
      }

      Map(position: $viewModel.cameraPosition) {
        Annotation("", coordinate: viewModel.pickupCoordinates) {
          PinView()
        }
      }
        .frame(width: 270, height: 270)
        .cornerRadius(135)
        .padding()

      Text("Would you like to pick up this passenger?")
        .foregroundStyle(.white)
        .padding(.horizontal, 16)

      Button {
        onAcceptButtonPressed?()
      } label: {
        Text("ACCEPT TRIP")
          .frame(maxWidth: .infinity, minHeight: 48)
          .foregroundStyle(.black)
          .font(.system(size: 20, weight: .bold))
      }
      .background()
      .padding(.horizontal, 24)

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .printFileOnAppear()
    .background(Color(uiColor: AppColors.backgroundColor))
  }
}

#Preview {
  @Previewable @StateObject var viewModel: PickupView.ViewModel = .init(trip: Trip.testData())
  PickupView(viewModel: viewModel)
}
