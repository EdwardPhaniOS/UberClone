//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import MapKit

struct PickupView: View {
  @StateObject var viewModel: PickupViewVM
  var onCloseButtonPressed: (() -> Void)?
  var onAcceptButtonPressed: (() -> Void)?
  
  init(trip: Trip, onCloseButtonPressed: (() -> Void)? = nil, onAcceptButtonPressed: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: PickupViewVM(trip: trip))
    self.onCloseButtonPressed = onCloseButtonPressed
    self.onAcceptButtonPressed = onAcceptButtonPressed
  }
  
  var body: some View {
    VStack(spacing: 8) {
      closeButtonView
        .padding(.leading, 16)
      mapView
      VStack {
        descriptionView
        actionButtonView
      }
      Spacer()
    }
    .padding()
    .printFileOnAppear()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
    .onAppear {
      viewModel.countDownToAcceptTrip {
        onCloseButtonPressed?()
      }
    }
    .onDisappear {
      viewModel.cancelCountdown()
    }
  }
}

private extension PickupView {
  var closeButtonView: some View {
    HStack{
      Button("", systemImage: "xmark") {
        viewModel.denyTrip(completion: {
          onCloseButtonPressed?()
        })
      }
      .font(.system(size: 18, weight: .bold))
      .foregroundStyle(Color.appTheme.accent)
      Spacer()
    }
  }
  
  var mapView: some View {
    Map(position: $viewModel.cameraPosition) {
      Annotation("", coordinate: viewModel.pickupCoordinates) {
        PinView()
      }
    }
    .frame(width: 270, height: 270)
    .cornerRadius(135)
    .shadow(AppShadow.regular)
    .padding()
  }
  
  var descriptionView: some View {
    Text("Would you like to pick up this passenger?")
      .foregroundStyle(Color.appTheme.text)
      .padding(.horizontal, 16)
  }
  
  var actionButtonView: some View {
    Text("ACCEPT TRIP (\(viewModel.countdown)s)")
      .primaryButton()
      .button(.press) {
        viewModel.acceptTrip(completion: {
          onAcceptButtonPressed?()
        })
      }
  }
}

#Preview {
  PickupView(trip: Trip.mock())
}
