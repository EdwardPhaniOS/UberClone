//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import FirebaseAuth
import MapKit

struct HomeView: View {
  @StateObject var viewModel: HomeViewVM
  var onMenuButtonPressed: (() -> Void)?
  
  init(user: User?, onMenuButtonPressed: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: HomeViewVM(user: user))
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
    .onChange(of: viewModel.searchText, { _, _ in
      viewModel.onSearchTextChange()
    })
    .printFileOnAppear()
    .infinityFrame()
    .showLoading(isLoading: viewModel.isLoading, message: viewModel.loadingMessage)
    .showError(item: $viewModel.error)
    .showAlert(item: $viewModel.appAlert)
    .fullScreenCover(isPresented: $viewModel.showPickupView, content: {
      PickupView(trip: viewModel.trip!, onCloseButtonPressed: {
        viewModel.showPickupView = false
      }, onAcceptButtonPressed: {
        viewModel.showPickupView = false
        viewModel.showRouteToPassenger()
      })
    })
  }

  var mapView: some View {
    Map(position: $viewModel.cameraPosition) {
      UserAnnotation()

      if viewModel.inputViewState != .hidden {
        ForEach(viewModel.driverAnnotations) { driver in
          Annotation("", coordinate: driver.coordinate) {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.black)
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
          .onTapGesture {
            viewModel.searchText = ""
            viewModel.showLocationInputView()
          }
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
          LocationInputView(onBackButtonPressed: { viewModel.showLocationInputActivationView()
          }, destinationLocation: $viewModel.searchText, userName: viewModel.user?.fullName ?? "")
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
              viewModel.showConfirmCancelTrip()
            }
            .foregroundStyle(Color.appTheme.accent)
            .frame(width: 48, height: 48)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(AppCornerRadius.button)
            .opacity(isBackButtonVisiable ? 1 : 0)

          Image("menu_ic")
            .plainButton()
            .button(.press) {
              onMenuButtonPressed?()
            }
            .frame(width: 48, height: 48)
            .background(Color.appTheme.cellBackground)
            .cornerRadius(AppCornerRadius.button)
            .opacity(isMenuButtonVisiable ? 1 : 0)
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
          viewModel.showConfirmCancelTrip()
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

extension HomeView {
  var isBackButtonVisiable: Bool {
    viewModel.inputViewState == .didSelectDestination
    && viewModel.trip?.state != .arrivedAtDestination
  }
  
  var isMenuButtonVisiable: Bool {
    viewModel.inputViewState == .inactive || viewModel.inputViewState == .hidden
  }
}

#Preview("Home View") {
  HomeView(user: User.mock, onMenuButtonPressed: nil)
}

