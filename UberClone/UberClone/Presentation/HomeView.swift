// Created on 10/24/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import FirebaseAuth
import MapKit

struct HomeView: View {
  @ObservedObject var viewModel: ViewModel
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    Map(position: $viewModel.cameraPosition) {
      UserAnnotation()
    }
    .mapControls({
      MapUserLocationButton()
      MapCompass()
    })
    .onAppear {
      viewModel.checkIfUserIsLoggedIn()
      viewModel.enableLocationServices()
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
}

#Preview("Home View") {
  let authViewModel = AuthViewModel()
  authViewModel.isLoggedIn = true

  return HomeView(viewModel: .init(authViewModel: authViewModel))
    .environmentObject(authViewModel)
}

extension HomeView {
  class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var cameraPosition = MapCameraPosition.region(
      MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    )

    private var authViewModel: AuthViewModel
    private let locationManager = CLLocationManager()

    init(authViewModel: AuthViewModel) {
      self.authViewModel = authViewModel
      super.init()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkIfUserIsLoggedIn() {
      let isLoggedIn = Auth.auth().currentUser?.uid != nil
      DispatchQueue.main.async {
        self.authViewModel.isLoggedIn = isLoggedIn
      }
    }

    func signOut() {
      do {
        try Auth.auth().signOut()
        authViewModel.isLoggedIn = false
      } catch {
        //Error when sign out
      }
    }

    func enableLocationServices() {
      let status = locationManager.authorizationStatus

      switch status {
      case .notDetermined:
        // Request only when-in-use unless you need background tracking
        locationManager.requestWhenInUseAuthorization()
      case .authorizedWhenInUse, .authorizedAlways:
        locationManager.startUpdatingLocation()
      case .denied, .restricted:
        print("Location access denied or restricted")
      @unknown default:
        break
      }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      switch manager.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
        manager.startUpdatingLocation()
      case .denied, .restricted:
        print("User denied location access")
      case .notDetermined:
        break
      @unknown default:
        break
      }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }

  }
}
