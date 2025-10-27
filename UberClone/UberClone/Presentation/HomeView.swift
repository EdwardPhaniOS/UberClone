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
          viewModel.fetchUserData()
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
    .printFileOnAppear()
  }

  var mapView: some View {
    Map(position: $viewModel.cameraPosition) {
      UserAnnotation()
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
        Spacer()
      }

      Group {
        List {
          Section("Saved Locations") {
            LocationRow()
            LocationRow()
          }

          Section {
            ForEach(0..<10) { index in
              LocationRow()
            }
          }
        }
        .padding(.top, 200)
        .listStyle(.grouped)

        VStack {
          LocationInputView(onBackButtonPressed: {
            viewModel.hideLocationInputView()
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

  return HomeView(viewModel: .init(authViewModel: authViewModel))
    .environmentObject(authViewModel)
}

