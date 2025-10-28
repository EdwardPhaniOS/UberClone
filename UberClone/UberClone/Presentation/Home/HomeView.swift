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
        .onAppear {
          viewModel.checkIfUserIsLoggedIn()
          viewModel.enableLocationServices()
        }
      inputView
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
    .mapControls({
      MapCompass()
      MapUserLocationButton()
    })
  }

  var inputView: some View {
    ZStack {
      VStack {
        LocationInputActivationView()
          .opacity(viewModel.inputActivationViewIsVisable ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: viewModel.inputActivationViewIsVisable)
          .padding(.top, 2)
          .padding(.horizontal, 16)
          .padding(.trailing, 50)
          .onTapGesture { viewModel.presentLocationInputView() }
        Button("Sign Out") {
          viewModel.signOut()
        }
        .opacity(viewModel.inputActivationViewIsVisable ? 1 : 0)
        Spacer()
      }

      Group {
        List {
          Section("Saved Locations") {
            LocationRow()
            LocationRow()
          }
          Section {
            ForEach(viewModel.placeMarks, id: \.self) { placeMark in
              LocationRow(title: placeMark.name ?? "", desc: placeMark.address)
            }
          }
        }
        .padding(.top, 200)
        .listStyle(.grouped)

        VStack {
          LocationInputView(onBackButtonPressed: {
            viewModel.hideLocationInputView()
          }, onSubmit: { _, query in
            viewModel.executeSearch(query: query)
          }, userName: $viewModel.userName)
          Spacer()
        }
      }
      .opacity(viewModel.inputViewIsVisable ? 1 : 0)
      .animation(.easeInOut(duration: 0.3), value: viewModel.inputViewIsVisable)
      .ignoresSafeArea()
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

