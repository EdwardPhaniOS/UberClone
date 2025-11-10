// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit
import FirebaseAuth
import CoreLocation

@MainActor
class HomeViewVM: NSObject, ObservableObject, LocationHandlerDelegate {
  
  enum InputViewState: Equatable {
    case notAvailable
    case inactive
    case active
    case didSelectPlacemark
  }
  
  enum AnnotationType: String {
    case pickup
    case destination
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
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  
  var trip: Trip?
  
  private var diContainer: DIContainer
  
  //MARK: - Init
  
  init(diContainer: DIContainer, user: User?) {
    self.diContainer = diContainer
    self.user = user
    super.init()
    LocationHandler.shared.delegate = self
  }
  
  //MARK: - APIs
  
  func passengerObserverCurrentTrip() {
    diContainer.passengerService.observeCurrentTrip { [weak self] trip in
      guard let self = self else { return }
      self.trip = trip
      
      guard let state = trip.state else { return }
      
      switch state {
      case .requested, .denied:
        break
      case .accepted:
        guard let driverUid = trip.driverUid else {
          self.isLoading = false
          return
        }
        
        if let selectedDriver = driverAnnotations.first(where: { $0.uuid == driverUid }) {
          driverAnnotations = [selectedDriver]
          zoomToFit(coordinates: [selectedDriver.coordinate, trip.pickupCoordinates])
        }
        
        diContainer.userService.fetchUserData(userId: driverUid) { driver in
          self.isLoading = false
          self.rideActionUser = driver
          self.rideActionViewState = .tripAccepted
        }
      case .driverArrived:
        self.isLoading = false
        self.rideActionViewState = .driverArrived
      case .inProgress:
        self.rideActionViewState = .tripInProgress
      case .arrivedAtDestination:
        self.rideActionViewState = .endTrip
      case .completed:
        diContainer.passengerService.deleteTrip { _, _ in
          self.clearRouteAndLocationSelection()
          self.fetchDrivers()
          self.showAlert = true
          self.alertMessage = "Trip Completed"
        }
      @unknown default:
        break
      }
    }
  }
  
  func setUpForCurrentUser() {
    guard let user = user else { return }
    
    self.driverAnnotations = []
    if user.accountType == .passenger {
      inputViewState = .inactive
      passengerObserverCurrentTrip()
      fetchDrivers()
    } else {
      driverObserveTrip()
      inputViewState = .notAvailable
    }
  }
  
  func fetchDrivers() {
    guard let location = LocationHandler.shared.location else { return }
    diContainer.passengerService.fetchDrivers(location: location) { [weak self] driver in
      guard let self = self else { return }
      guard let coordinate = driver.location?.coordinate else { return }
      
      let tripIsActive = trip?.driverUid != nil
      
      if tripIsActive {
        if driver.uuid != trip?.driverUid {
          return
        }
        
        if let pickupCoordinates = trip?.pickupCoordinates, let driverCoordinates = driver.location?.coordinate {
          zoomToFit(coordinates: [pickupCoordinates, driverCoordinates])
        }
      }
      
      let annotation = DriverAnnotation(uuid: driver.uuid, coordinate: coordinate)
      
      if let index = self.driverAnnotations.firstIndex(where: { $0.uuid == annotation.uuid }) {
        self.driverAnnotations[index] = annotation
      } else {
        self.driverAnnotations.append(annotation)
      }
    }
  }
  
  func uploadTrip() {
    guard let pickupCoordinate = LocationHandler.shared.location?.coordinate else { return }
    guard let destinationCoordinate = selectedPlacemark?.coordinate else { return }
    
    isLoading = true
    loadingMessage = "Finding your ride now.."
    diContainer.passengerService.uploadTrip(pickupCoordinate: pickupCoordinate, destinationCoordinate: destinationCoordinate) { [weak self] err, ref in
      guard let self = self else { return }
      
      if let err = err {
        print("DEBUG: Error - \(err.localizedDescription)")
      }
      
      self.rideActionViewState = .notAvailable
    }
  }
  
  func driverObserveTrip() {
    diContainer.driverService.observeTrip { [weak self] trip in
      guard let self = self else { return }
      
      self.showPickupView = trip.state == .requested
      self.trip = trip
      
      if trip.state == .accepted {
        driverAcceptTrip()
        
        guard let location = LocationHandler.shared.location else { return }
        diContainer.driverService.updateDriverLocation(location: location, completion: { _ in })
      }
    }
  }
  
  func observeCancelledTrip(trip: Trip) {
    diContainer.driverService.observeTripCancelled(trip: trip) { [weak self] in
      guard let self = self else { return }
      
      rideActionViewState = .notAvailable
      selectedPlacemark = nil
      routeCoordinates = nil
      zoomToCurrentUser()
      
      showAlert = true
      alertMessage = "The passenger has decided to cancel this ride. Press OK to continue"
    }
  }
  
  func driverAcceptTrip() {
    guard trip != nil else { return }
    
    isLoading = true
    diContainer.driverService.acceptTrip(trip: trip!) { [weak self] error, ref in
      guard let self = self else { return }
      
      self.trip?.state = .accepted
      self.trip?.driverUid = Auth.auth().currentUser?.uid
      
      self.observeCancelledTrip(trip: trip!)
      
      self.setCustomRegion(withAnnotationType: .pickup, withCoordinates: trip!.pickupCoordinates)
      
      let pickupCoordinates = trip!.pickupCoordinates!
      let location = CLLocation(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude)
      CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
        guard let self = self else { return }
        self.isLoading = false
        
        if let placeMark = placemarks?.first {
          let mapKitPlacemark = MKPlacemark(placemark: placeMark)
          
          diContainer.userService.fetchUserData(userId: trip!.passengerUid) { user in
            self.rideActionUser = user
            self.selectedPlacemark = mapKitPlacemark
            self.rideActionViewState = .tripAccepted
            self.calculateRoute(to: mapKitPlacemark)
          }
        }
      }
    }
  }
  
  func cancelTrip() {
    isLoading = true
    diContainer.passengerService.deleteTrip { [weak self] error, ref in
      guard let self = self else { return }
      isLoading = false
      
      self.trip?.state = .denied
      self.trip?.driverUid = nil
      self.clearRouteAndLocationSelection()
      self.fetchDrivers()
    }
  }
  
  func startTrip() {
    guard let trip = self.trip else { return }
    
    isLoading = true
    diContainer.driverService.updateTripState(trip: trip, state: .inProgress) { [weak self] err, ref in
      guard let self = self,
            let destinationCoordinates = trip.destinationCoordinates,
            let driverCoordinates = LocationHandler.shared.location?.coordinate
      else {
        self?.isLoading = false
        return
      }
      
      let location = CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude)
      CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
        guard let self = self else { return }
        self.isLoading = false
        
        if let placeMark = placemarks?.first {
          let mapKitPlacemark = MKPlacemark(placemark: placeMark)
          self.rideActionViewState = .tripInProgress
          self.selectedPlacemark = mapKitPlacemark
          self.calculateRoute(to: mapKitPlacemark)
          self.setCustomRegion(withAnnotationType: .destination, withCoordinates: destinationCoordinates)
          self.zoomToFit(coordinates: [driverCoordinates, destinationCoordinates])
        }
      }
    }
  }
  
  func dropOff() {
    guard let trip = self.trip else { return }
    
    isLoading = true
    self.trip?.state = .completed
    diContainer.driverService.updateTripState(trip: trip, state: .completed) { [weak self] err, ref in
      guard let self = self else { return }
      self.isLoading = false
      
      rideActionViewState = .notAvailable
      selectedPlacemark = nil
      routeCoordinates = nil
      zoomToCurrentUser()
    }
  }
  
  //MARK: - Location Handling
  
  func enableLocationServices() {
    LocationHandler.shared.enableLocationServices()
  }
  
  nonisolated func didUpdateLocations(location: CLLocation) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.cameraPosition = .region(
        MKCoordinateRegion(
          center: location.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      )
      
      if user?.accountType == .driver {
        diContainer.driverService.updateDriverLocation(location: location, completion: { _ in })
      } else {
        self.fetchDrivers()
      }
    }
  }
  
  nonisolated func didStartMonitoringFor(region: CLRegion) {
    print("DEBUG - didStartMonitoringFor region.identifier: \(region.identifier)")
  }
  
  nonisolated func didEnterRegion(region: CLRegion) {
    let regionId = region.identifier
    
    DispatchQueue.main.async {
      guard let trip = self.trip else { return }
      
      if regionId == AnnotationType.pickup.rawValue {
        self.diContainer.driverService.updateTripState(trip: trip, state: .driverArrived) { err, ref in
          DispatchQueue.main.async {
            self.rideActionViewState = .pickupPassenger
          }
        }
      }
      
      if regionId == AnnotationType.destination.rawValue {
        self.diContainer.driverService.updateTripState(trip: trip, state: .arrivedAtDestination) { err, ref in
          DispatchQueue.main.async {
            self.rideActionViewState = .endTrip
          }
        }
      }
      
    }
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
        self.routeCoordinates = coords
        self.zoomToFit(coordinates: coords)
      } else {
        self.routeCoordinates = nil
      }
    }
  }
  
  func zoomToFit(coordinates: [CLLocationCoordinate2D]) {
    if coordinates.isEmpty {
      return
    }
    
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
    
    let bottomInset: Double = 0.05
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                        longitude: (minLon + maxLon)/2)
    let span = MKCoordinateSpan(latitudeDelta: max(0.01, maxLat - minLat + 0.01 + bottomInset),
                                longitudeDelta: max(0.01, maxLon - minLon + 0.01))
    withAnimation(.easeInOut(duration: 0.3)) {
      self.cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
  }
  
  func zoomToCurrentUser() {
    guard let currentCoordinate = LocationHandler.shared.location?.coordinate else { return }
    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    withAnimation(.easeInOut(duration: 0.3)) {
      self.cameraPosition = .region(MKCoordinateRegion(center: currentCoordinate, span: span))
    }
  }
  
  func setCustomRegion(withAnnotationType type: AnnotationType, withCoordinates coordinates: CLLocationCoordinate2D) {
    let region = CLCircularRegion(center: coordinates, radius: 100, identifier: type.rawValue)
    LocationHandler.shared.locationManager.startMonitoring(for: region)
  }
  
}
