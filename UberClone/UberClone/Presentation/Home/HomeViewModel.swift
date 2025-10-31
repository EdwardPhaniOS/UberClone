// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit
import FirebaseAuth
import CoreLocation

extension HomeView {
  class ViewModel: NSObject, ObservableObject, LocationHandlerDelegate {

    enum InputViewState: Equatable {
      case notAvailable
      case inactive
      case active
      case didSelectPlacemark
    }

    //MARK: - Variables
    
    @Published var cameraPosition = MapCameraPosition.region(
      MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      )
    )

    @Published var user: User?
    @Published var rideActionUser: User?
    @Published var driverAnnotations: [DriverAnnotation] = []
    @Published var placemarks: [MKPlacemark] = []
    @Published var selectedPlacemark: MKPlacemark?
    @Published var inputViewState: InputViewState = .notAvailable
    @Published var rideActionViewState: RideActionViewState = .notAvailable
    @Published var routeCoordinates: [CLLocationCoordinate2D]? = nil
    @Published var showPickupView: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String = ""

    var trip: Trip?

    private var authViewModel: AuthViewModel

    //MARK: - Init

    init(authViewModel: AuthViewModel) {
      self.authViewModel = authViewModel
      super.init()
      LocationHandler.shared.delegate = self
    }

    //MARK: - APIs

    func observerCurrentTrip() {
      Service.shared.observeCurrentTrip { [weak self] trip in
        guard let self = self else { return }
        self.trip = trip

        if trip.state == .accepted {
          guard let driverUid = trip.driverUid else {
            self.isLoading = false
            return
          }
          Service.shared.fetchUserData(userId: driverUid) { driver in
            self.isLoading = false
            self.rideActionUser = driver
            self.rideActionViewState = .tripAccepted
          }
        }
      }
    }

    func fetchUserData() {
      guard let currentUserId = Auth.auth().currentUser?.uid else { return }
      Service.shared.fetchUserData(userId: currentUserId) { [weak self] user in
        guard let self = self else { return }

        DispatchQueue.main.async {
          self.user = user
        }

        self.driverAnnotations = []
        if user.accountType == .passenger {
          fetchDrivers()
          inputViewState = .inactive
          observerCurrentTrip()
        } else {
          observeTrip()
          inputViewState = .notAvailable
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
        print("DEBUG: Error - \(error.localizedDescription)")
      }
    }

    func uploadTrip() {
      guard let pickupCoordinate = LocationHandler.shared.location?.coordinate else { return }
      guard let destinationCoordinate = selectedPlacemark?.coordinate else { return }

      isLoading = true
      loadingMessage = "Finding your ride now.."
      Service.shared.uploadTrip(pickupCoordinate: pickupCoordinate, destinationCoordinate: destinationCoordinate) { [weak self] err, ref in
        guard let self = self else { return }

        if let err = err {
          print("DEBUG: Error - \(err.localizedDescription)")
        }

        self.rideActionViewState = .notAvailable
      }
    }

    func observeTrip() {
      Service.shared.observeTrip { [weak self] trip in
        guard let self = self else { return }

        DispatchQueue.main.async {
          self.showPickupView = true
          self.trip = trip
        }
      }
    }

    func acceptTrip() {
      guard trip != nil else { return }

      isLoading = true
      Service.shared.acceptTrip(trip: trip!) { [weak self] error, ref in
        guard let self = self else { return }

        self.trip?.state = .accepted
        self.trip?.driverUid = Auth.auth().currentUser?.uid

        let pickupCoordinates = trip!.pickupCoordinates!
        let location = CLLocation(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
          guard let self = self else { return }
          self.isLoading = false

          if let placeMark = placemarks?.first {
            let mapKitPlacemark = MKPlacemark(placemark: placeMark)


            Service.shared.fetchUserData(userId: trip!.passengerUid) { user in
              self.rideActionUser = user
              self.selectedPlacemark = mapKitPlacemark
              self.rideActionViewState = .tripAccepted
              self.calculateRoute(to: mapKitPlacemark)
            }
          }
        }
      }
    }

    //MARK: - Location Handling

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

      self.fetchUserData()
    }

    //MARK: - Location Input & Search Management

    func showLocationInputView() {
      inputViewState = .active
    }

    func showLocationInputActivationView() {
      inputViewState = .inactive
      placemarks = []
    }

    func clearRouteAndLocationSelection() {
      showLocationInputActivationView()
      rideActionViewState = .notAvailable
      selectedPlacemark = nil
      routeCoordinates = nil
      zoomToCurrentUser()
    }

    func searchPlacemarks(query: String) {
      self.placemarks = []

      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = query
      if let region = cameraPosition.region {
        request.region = region
      }

      let searchTask = MKLocalSearch(request: request)
      searchTask.start { [weak self] response, error in
        guard let self = self else { return }
        guard let response = response else { return }

        response.mapItems.forEach { item in
          DispatchQueue.main.async {
            self.placemarks.append(item.placemark)
          }
        }
      }
    }

    func selectPlacemark(placemark: MKPlacemark) {
      selectedPlacemark = placemark
      inputViewState = .didSelectPlacemark
      rideActionViewState = .requestRide
      calculateRoute(to: placemark)
    }

    //MARK: - Map & Route Handling

    func calculateRoute(to placemark: MKPlacemark) {
      guard let currentCoordinate = LocationHandler.shared.location?.coordinate else { return }

      let request = MKDirections.Request()
      request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentCoordinate))
      request.destination = MKMapItem(placemark: placemark)
      request.transportType = .automobile
      request.requestsAlternateRoutes = false

      let directionsTask = MKDirections(request: request)
      directionsTask.calculate { [weak self] response, error in
        guard let self = self else { return }
        if let route = response?.routes.first {
          let count = route.polyline.pointCount
          var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
          route.polyline.getCoordinates(&coords, range: NSRange(location: 0, length: count))
          DispatchQueue.main.async {
            self.routeCoordinates = coords
            self.zoomToRoute()
          }
        } else {
          DispatchQueue.main.async {
            self.routeCoordinates = nil
          }
        }
      }
    }

    func zoomToRoute() {
      guard let coordinates = routeCoordinates, !coordinates.isEmpty else { return }

      var minLat = coordinates.first!.latitude
      var maxLat = coordinates.first!.latitude
      var minLon = coordinates.first!.longitude
      var maxLon = coordinates.first!.longitude

      for coordinate in coordinates {
        minLat = min(minLat, coordinate.latitude)
        maxLat = max(maxLat, coordinate.latitude)
        minLon = min(minLon, coordinate.longitude)
        maxLon = max(maxLon, coordinate.longitude)
      }

      let bottomInset: Double = 0.01
      let center = CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                          longitude: (minLon + maxLon)/2)
      let span = MKCoordinateSpan(latitudeDelta: max(0.01, maxLat - minLat + 0.01 + bottomInset),
                                  longitudeDelta: max(0.01, maxLon - minLon + 0.01))
      DispatchQueue.main.async {
        withAnimation(.easeInOut(duration: 0.3)) {
          self.cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
      }
    }

    func zoomToCurrentUser() {
      guard let currentCoordinate = LocationHandler.shared.location?.coordinate else { return }
      let center = CLLocationCoordinate2D(latitude: currentCoordinate.latitude,
                                          longitude: currentCoordinate.longitude)
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      DispatchQueue.main.async {
        withAnimation(.easeInOut(duration: 0.3)) {
          self.cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
      }
    }
  }

}
