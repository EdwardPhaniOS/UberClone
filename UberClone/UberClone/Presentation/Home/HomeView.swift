// Created on 10/24/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import MapKit

struct HomeView: View {
  @StateObject var viewModel: HomeViewVM
  var onMenuButtonPressed: (() -> Void)?
  
  init(diContainer: DIContainer, user: User?, onMenuButtonPressed: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: HomeViewVM(diContainer: diContainer, user: user))
    self.onMenuButtonPressed = onMenuButtonPressed
  }

  var body: some View {
    ZStack {
      mapView
      inputView
      menuButton
      confirmRidePopup
    }
    .onDisappear(perform: {
      viewModel.removeAllListener()
    })
    .printFileOnAppear()
    .showLoading(isLoading: viewModel.isLoading, message: viewModel.loadingMessage)
    .fullScreenCover(isPresented: $viewModel.showPickupView, content: {
      PickupView(diContainer: viewModel.diContainer, trip: viewModel.trip!, onCloseButtonPressed: {
        viewModel.showPickupView = false
      }, onAcceptButtonPressed: {
        viewModel.driverAcceptTrip()
        viewModel.showPickupView = false
      })
    })
    .alert("", isPresented: $viewModel.showAlert) { 
      Button("OK", role: .cancel, action: {})
    } message: {
      Text(viewModel.alertMessage)
    }
  }

  var mapView: some View {
    Map(position: $viewModel.cameraPosition) {
      UserAnnotation()

      if viewModel.inputViewState != .notAvailable {
        ForEach(viewModel.driverAnnotations) { driver in
          Annotation("", coordinate: driver.coordinate) {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.appTheme.inProgress)
                .frame(width: 25, height: 25)
              Image(systemName: "car")
                .foregroundStyle(Color.white)
                .font(.system(size: 14))
            }
          }
        }
      }

      if let selectedPlacemark = viewModel.selectedPlacemark {
        Annotation("", coordinate: selectedPlacemark.coordinate) {
          PinView()
        }
      }

      if let coordinates = viewModel.routeCoordinates, !coordinates.isEmpty {
        MapPolyline(coordinates: coordinates)
          .stroke(Color.appTheme.miscellaneous, lineWidth: 5)
      }
    }
    .mapControls({
      MapCompass()
      MapUserLocationButton()
    })
  }

  var inputView: some View {
    ZStack {
      VStack {
        LocationInputActivationView()
          .opacity(viewModel.inputViewState == .inactive ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: viewModel.inputViewState)
          .padding(.top, 58)
          .padding(.horizontal, 32)
          .onTapGesture { viewModel.showLocationInputView() }
          .opacity(viewModel.inputViewState == .inactive ? 1 : 0)
        Spacer()
      }

      Group {
        List {
          Section("Saved Locations") {
            ForEach(viewModel.savedPlacemarks, id: \.self) { placemark in
              LocationRow(title: placemark.name ?? "", desc: placemark.address)
                .onTapGesture {
                  viewModel.selectPlacemark(placemark: placemark)
                }
            }
          }
          Section(viewModel.placemarks.isEmpty ? "" : "Results") {
            ForEach(viewModel.placemarks, id: \.self) { placemark in
              LocationRow(title: placemark.name ?? "", desc: placemark.address)
                .onTapGesture {
                  viewModel.selectPlacemark(placemark: placemark)
                }
            }
          }
        }
        .padding(.top, 200)
        .listStyle(.grouped)

        VStack {
          LocationInputView(onBackButtonPressed: {
            viewModel.showLocationInputActivationView()
          }, onSubmit: { _, query in
            viewModel.searchPlacemarks(query: query)
          }, userName: viewModel.user?.fullName ?? "")
          Spacer()
        }
      }
      .opacity(viewModel.inputViewState == .active ? 1 : 0)
      .animation(.easeInOut(duration: 0.3), value: viewModel.inputViewState)
      .ignoresSafeArea()
    }
  }

  var menuButton: some View {
    VStack {
      HStack {
        ZStack(content: {
          Image(systemName: "arrow.backward")
            .plainButton()
            .button(.press) {
              viewModel.cancelTrip()
            }
            .foregroundStyle(Color.appTheme.accent)
            .frame(width: 48, height: 48)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(AppCornerRadius.button)
            .opacity(viewModel.inputViewState == .didSelectPlacemark ? 1 : 0)

          Image("menu_ic")
            .plainButton()
            .button(.press) {
              onMenuButtonPressed?()
            }
            .frame(width: 48, height: 48)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(AppCornerRadius.button)
            .opacity((viewModel.inputViewState == .inactive || viewModel.inputViewState == .notAvailable) ? 1 : 0)
        })
        .animation(.easeInOut(duration: 0.3), value: viewModel.inputViewState)
        .foregroundStyle(Color.appTheme.accent)
        .padding(.top, 4)
        .padding(.leading, 16)
        Spacer()
      }
      Spacer()
    }
  }

  var confirmRidePopup: some View {
    VStack {
      Spacer()
      RideActionView(state: viewModel.rideActionViewState, destination: viewModel.selectedPlacemark, user: viewModel.rideActionUser, onConfirmButtonPressed: { buttonAction in

        switch buttonAction {
        case .requestRide:
          viewModel.uploadTrip()
        case .cancel:
          viewModel.cancelTrip()
        case .getDirections:
          break
        case .pickup:
          viewModel.startTrip()
        case .inProgress:
          break
        case .arrived:
          break
        case .dropOff:
          viewModel.dropOff()
        }
      })
    }
    .ignoresSafeArea()
    .opacity(viewModel.rideActionViewState != .notAvailable ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: viewModel.rideActionViewState)
  }

}

#Preview("Home View") {
  HomeView(diContainer: DIContainer.mock, user: User.mock, onMenuButtonPressed: nil)
}

