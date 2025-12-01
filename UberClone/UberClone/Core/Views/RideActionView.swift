//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import MapKit

enum RideActionViewState: Equatable {
  case notAvailable
  case requestRide
  case tripAccepted
  case driverArrived
  case pickupPassenger
  case tripInProgress
  case endTrip
}

enum RideActionViewButtonAction {
  case requestRide
  case cancel
  case getDirections
  case pickup
  case inProgress
  case arrived
  case dropOff
  
  var description: String {
    switch self {
    case .requestRide: return "CONFIRM UBERX"
    case .cancel: return "CANCEL RIDE"
    case .getDirections: return "GET DIRECTIONS"
    case .pickup: return "PICKUP PASSENGER"
    case .dropOff: return "DROP OFF PASSENGER"
    case .inProgress: return "TRIP IN PROGRESS"
    case .arrived: return "ARRIVED AT DESTINATION"
    }
  }
}

struct RideActionView: View {
  
  var state: RideActionViewState
  var destination: MKPlacemark?
  var user: User?
  
  var onConfirmButtonPressed: ((RideActionViewButtonAction) -> Void)?
  
  var body: some View {
    VStack(spacing: 16) {
      infoView
      Rectangle()
        .frame(maxWidth: .infinity, maxHeight: 0.5)
        .foregroundStyle(Color.gray)
      actionButtonView
    }
    .padding()
    .background(Color.appTheme.viewBackground)
  }
}

private extension RideActionView {
  var infoView: some View {
    VStack {
      Text(title)
        .font(.title2)
      Text(description)
        .font(.system(size: 16))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .frame(width: 48, height: 48)
          .foregroundStyle(Color.appTheme.alternateAccent)
        Text(infoText)
          .foregroundStyle(Color.appTheme.accentContrastText)
          .font(.system(size: 24))
      }
      Text(state == .requestRide ? "UberX" : "\(user?.fullName ?? "")")
    }
  }
  
  var actionButtonView: some View {
    Text(buttonAction.description)
      .primaryButton()
      .button(.press) {
        onConfirmButtonPressed?(buttonAction)
      }
      .disabled(enableButton)
  }
}

private extension RideActionView {
  var infoText: String {
    switch state {
    case .requestRide:
      return "X"
    default:
      return String(user?.fullName.first ?? "X")
    }
  }
  
  var title: String {
    switch state {
    case .notAvailable, .requestRide:
      return destination?.name ?? ""
    case .tripAccepted:
      return user?.accountType == .driver ? "Driver En Route" : "En Route To Passenger"
    case .driverArrived:
      return user?.accountType == .driver ? "Driver Has Arrived" : "Arrived At Passenger Location"
    case .pickupPassenger:
      return "Arrived At Passenger Location"
    case .tripInProgress:
      return "En Route To Destination"
    case .endTrip:
      return "Arrived At Destination"
      
    }
  }
  
  var description: String {
    if state == .driverArrived {
      return "Please meet driver at pickup location"
    } else if state == .pickupPassenger {
      return ""
    }
    
    return destination?.address ?? ""
  }
  
  var enableButton: Bool {
    if buttonAction == .inProgress || buttonAction == .arrived || buttonAction == .getDirections {
      return true
    }
    
    return false
  }
  
  var buttonAction: RideActionViewButtonAction {
    switch state {
    case .tripAccepted:
      return user?.accountType == .passenger ? .getDirections : .cancel
    case .pickupPassenger:
      return .pickup
    case .driverArrived:
      return .cancel
    case .tripInProgress:
      return user?.accountType == .driver ? .inProgress : .getDirections
    case .endTrip:
      return user?.accountType == .driver ? .arrived : .dropOff
    case .notAvailable, .requestRide:
      return .requestRide
    @unknown default:
      return .requestRide
    }
  }
}

fileprivate struct PreviewView: View {
  var body: some View {
    RideActionView(state: .requestRide)
  }
}

#Preview {
  PreviewView()
}
