// Created on 10/24/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import MapKit

struct HomeView: View {
  @ObservedObject var viewModel: ViewModel
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    ZStack {
      mapView
      inputView
      menuButton
    }
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
    .onAppear {
      viewModel.checkIfUserIsLoggedIn()
      viewModel.enableLocationServices()
    }
    .onChange(of: authViewModel.isLoggedIn) { _, isLoggedIn in
      if isLoggedIn {
        viewModel.fetchUserData()
        viewModel.fetchDrivers()
      }
    }
    .printFileOnAppear()
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
          ZStack {
            RoundedRectangle(cornerRadius: 2)
              .foregroundStyle(Color.orange)
              .frame(width: 4, height: 4)
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(.orange)
              .font(.system(size: 28))
              .offset(y: -20)
            Image(systemName: "arrowtriangle.down.fill")
              .foregroundStyle(.orange)
              .font(.system(size: 8))
              .offset(y: -5)
          }
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
            viewModel.executeSearch(query: query)
          }, userName: $viewModel.userName)
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
            viewModel.showLocationInputActivationView()
            viewModel.selectedPlacemark = nil
            viewModel.routeCoordinates = nil
            viewModel.zoomToCurrentUser()
          }
          .foregroundStyle(.black)
          .font(.system(size: 18, weight: .bold))
          .opacity(viewModel.inputViewState == .didSelectPlacemark ? 1 : 0)

          Button("", image: ImageResource(name: "menu_ic", bundle: .main)) {
            //TODO: handle menu button
            viewModel.signOut()
          }
          .font(.system(size: 18, weight: .bold))
          .opacity(viewModel.inputViewState == .inactive ? 1 : 0)

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

}

#Preview("Home View") {
  let authViewModel = AuthViewModel()
  authViewModel.isLoggedIn = true

  let viewModel = HomeView.ViewModel(authViewModel: authViewModel)
  viewModel.driverAnnotations.append(contentsOf: DriverAnnotation.testData())

  return HomeView(viewModel: viewModel)
    .environmentObject(authViewModel)
}

