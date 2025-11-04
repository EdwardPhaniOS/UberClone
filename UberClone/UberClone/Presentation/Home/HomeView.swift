// Created on 10/24/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import MapKit

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewVM
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    ZStack {
      mapView
      inputView
      menuButton
      confirmRidePopup
    }
    .onAppear {
      viewModel.checkIfUserIsLoggedIn()
      viewModel.enableLocationServices()
    }
    .onChange(of: authViewModel.isLoggedIn) { _, isLoggedIn in
      if isLoggedIn {
        viewModel.fetchUserData()
      }
    }
    .printFileOnAppear()
    .showLoadingView(isLoading: viewModel.isLoading, message: viewModel.loadingMessage)
    .fullScreenCover(
      isPresented: Binding(
        get: { !authViewModel.isLoggedIn },
        set: { _ in }
      )
    ) {
      NavigationStack {
        LoginView(viewModel: .init(authViewModel: authViewModel))
      }
    }
    .fullScreenCover(isPresented: $viewModel.showPickupView, content: {
      PickupView(viewModel: .init(trip: viewModel.trip!), onCloseButtonPressed: {
        viewModel.showPickupView = false
      }, onAcceptButtonPressed: {
        viewModel.acceptTrip()
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

      if viewModel.inputViewState == .inactive {
        ForEach(viewModel.driverAnnotations) { driver in
          Annotation("", coordinate: driver.coordinate) {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(uiColor: AppColors.backgroundColor))
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
          .stroke(Color(uiColor: AppColors.mainBlueTint), lineWidth: 5)
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
            LocationRow()
            LocationRow()
          }
          Section {
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
          Button("", systemImage: "arrow.backward") {
            viewModel.clearRouteAndLocationSelection()
          }
          .foregroundStyle(.black)
          .font(.system(size: 18, weight: .bold))
          .opacity(viewModel.inputViewState == .didSelectPlacemark ? 1 : 0)

          Button("", image: ImageResource(name: "menu_ic", bundle: .main)) {
            //TODO: handle menu button
            viewModel.signOut()
            viewModel.clearRouteAndLocationSelection()
          }
          .font(.system(size: 18, weight: .bold))
          .opacity((viewModel.inputViewState == .inactive || viewModel.inputViewState == .notAvailable) ? 1 : 0)

        })
        .animation(.easeInOut(duration: 0.3), value: viewModel.inputViewState)
        .foregroundStyle(Color(uiColor: AppColors.backgroundColor))
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
          print("DEBUG - getDirections")
        case .pickup:
          print("DEBUG - pickup")
        case .inProgress:
          print("DEBUG - inProgress")
        case .arrived:
          print("DEBUG - arrived")
        case .dropOff:
          print("DEBUG - dropOff")
        }
      })
    }
    .ignoresSafeArea()
    .opacity(viewModel.rideActionViewState != .notAvailable ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: viewModel.rideActionViewState)
  }

}

#Preview("Home View") {
  let authViewModel = AuthViewModel()
  authViewModel.isLoggedIn = true

  let viewModel = HomeViewVM(authViewModel: authViewModel)
  viewModel.driverAnnotations.append(contentsOf: DriverAnnotation.testData())

  return HomeView(viewModel: viewModel)
    .environmentObject(authViewModel)
}

