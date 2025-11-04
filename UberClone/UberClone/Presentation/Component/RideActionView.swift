// Created on 10/30/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

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
        ZStack {
          RoundedRectangle(cornerRadius: 24)
            .frame(width: 48, height: 48)
            .foregroundStyle(Color.black)
          Text(infoText)
            .foregroundStyle(Color.white)
            .font(.system(size: 24))
        }
        .padding(.top, 8)
        
        Text(state == .requestRide ? "UberX" : "\(user?.fullName ?? "")")
        
        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 0.5)
          .foregroundStyle(Color.gray)
        Button {
          onConfirmButtonPressed?(buttonAction)
        } label: {
          Text(buttonAction.description)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(Color.white)
        }
        .disabled(enableButton)
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
    if buttonAction == .inProgress || buttonAction == .arrived {
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

#Preview {
  RideActionView(state: .requestRide)
}
