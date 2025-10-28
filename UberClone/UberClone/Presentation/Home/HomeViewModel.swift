// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit
import FirebaseAuth

extension HomeView {
  class ViewModel: NSObject, ObservableObject, LocationHandlerDelegate {

    @Published var cameraPosition = MapCameraPosition.region(
      MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    )

    @Published var inputActivationViewIsVisable: Bool = true
    @Published var inputViewIsVisable: Bool = false
    @Published var userName: String = ""
    @Published var driverAnnotations: [DriverAnnotation] = []

    private var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
      self.authViewModel = authViewModel
      super.init()
      LocationHandler.shared.delegate = self
    }

    func fetchUserData() {
      guard let currentUserId = Auth.auth().currentUser?.uid else { return }
      Service.shared.fetchUserData(userId: currentUserId) { [weak self] user in
        DispatchQueue.main.async {
          self?.userName = user.fullName
        }
      }
    }

    func fetchDrivers() {
      guard let location = LocationHandler.shared.location else { return }
      Service.shared.fetchDrivers(location: location) { [weak self] driver in
        guard let self = self else { return }
        guard let coordinate = driver.location?.coordinate else { return }

        let annotation = DriverAnnotation(uuid: driver.uuid, coordinate: coordinate)

        if let index = self.driverAnnotations.firstIndex(where: { $0.uuid == annotation.uuid }) {
          DispatchQueue.main.async {
            self.driverAnnotations[index] = annotation
          }

        } else {
          DispatchQueue.main.async {
            self.driverAnnotations.append(annotation)
          }
        }
      }
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
        DispatchQueue.main.async {
          self.authViewModel.isLoggedIn = false
        }
      } catch {
        //Error when sign out
      }
    }

    func enableLocationServices() {
      LocationHandler.shared.enableLocationServices()
    }

    func didUpdateLocations(location: CLLocation) {
      DispatchQueue.main.async {
          self.cameraPosition = .region(
              MKCoordinateRegion(
                  center: location.coordinate,
                  span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
              )
          )
      }
    }

    func presentLocationInputView() {
      inputViewIsVisable = true
      inputActivationViewIsVisable = false
    }

    func hideLocationInputView() {
      inputViewIsVisable = false
      inputActivationViewIsVisable = true
    }
  }
}
