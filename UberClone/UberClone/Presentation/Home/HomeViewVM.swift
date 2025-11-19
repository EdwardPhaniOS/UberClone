// Created on 10/27/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI
import MapKit
import FirebaseAuth
import CoreLocation
import Combine

@MainActor
class HomeViewVM: NSObject, ObservableObject, ErrorDisplayable {
  
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
  @Published var savedPlacemarks: [MKPlacemark] = []
  @Published var selectedPlacemark: MKPlacemark?
  @Published var inputViewState: InputViewState = .notAvailable
  @Published var rideActionViewState: RideActionViewState = .notAvailable
  @Published var routeCoordinates: [CLLocationCoordinate2D]? = nil
  @Published var showPickupView: Bool = false
  @Published var isLoading: Bool = false
  @Published var loadingMessage = ""
  @Published var searchText = ""
  @Published var error: Error?
  @Published var appAlert: AppAlert?
  var debounceTimer: Timer?
  var cancellables: Set<AnyCancellable> = Set()
  
  var trip: Trip?
  
  var diContainer: DIContainer
  
  //MARK: - Init
  
  init(diContainer: DIContainer, user: User?) {
    self.diContainer = diContainer
    self.user = user
    super.init()
    
    configureInitialViewState()
    setSubscribers()
  }
  
  func configureInitialViewState() {
    guard let user = user else { return }
    
    self.driverAnnotations = []
    if user.accountType == .passenger {
      inputViewState = .inactive
    } else {
      inputViewState = .notAvailable
    }
  }
  
  func showAlertOnUI(message: String) {
    appAlert = AppAlert(title: "", message: message)
  }
  
  //MARK: - APIs
  
  func setSubscribers() {
    guard let user = user else { return }
    if user.accountType == .passenger {
      passengerObserverCurrentTrip()
      fetchDrivers()
    } else {
      driverObserveTrip()
    }
    
    LocationHandler.shared.uploadLocationPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] location in
        guard let self = self else { return }
        guard let location = location else { return }
        self.updateLocations(location: location)
      }
      .store(in: &cancellables)
    
    LocationHandler.shared.enterRegionPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] region in
        guard let self = self else { return }
        guard let region = region else { return }
        self.driverDidEnterRegion(region: region)
      }
      .store(in: &cancellables)
  }
  
  func passengerObserverCurrentTrip() {
    diContainer.passengerService.observeCurrentTrip()
      .sink { _ in } receiveValue: { [weak self] trip in
        guard let self = self else { return }
        self.trip = trip
        guard let state = trip.state else { return }
        
        switch state {
        case .requested:
          break
        case .denied:
          Task(handlingError: self) { [weak self] in
            guard let self = self else { return }
            
            try await diContainer.passengerService.deleteTrip()
            
            self.clearRouteAndLocationSelection()
            self.fetchDrivers()
            self.isLoading = false
            self.showAlertOnUI(message: "Trip was denied")
          }
          
        case .accepted:
          guard let driverUid = trip.driverUid else {
            self.isLoading = false
            return
          }
          
          if let selectedDriver = driverAnnotations.first(where: { $0.uuid == driverUid }) {
            driverAnnotations = [selectedDriver]
            zoomToFit(coordinates: [selectedDriver.coordinate, trip.pickupCoordinates])
          }
          
          Task(handlingError: self) { [weak self] in
            guard let self = self else { return }
            defer { isLoading = false }
            let driver = try await diContainer.userService.fetchUserData(userId: driverUid)
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
          Task(handlingError: self) { [weak self] in
            guard let self = self else { return }
            
            try await diContainer.passengerService.deleteTrip()
            
            self.clearRouteAndLocationSelection()
            self.fetchDrivers()
            self.showAlertOnUI(message: "Trip Completed")
          }
          
        @unknown default:
          break
        }
      }
      .store(in: &cancellables)
  }
  
  func fetchDrivers() {
    guard let location = LocationHandler.shared.location else { return }
    
    diContainer.passengerService.fetchDrivers(location: location)
      .receive(on: DispatchQueue.main)
      .sink { _ in } receiveValue: { [weak self] driver in
        guard let self = self else { return }
        
        guard let coordinate = driver.location?.coordinate else { return }
        
        let tripIsActive = trip?.driverUid != nil
        
        if tripIsActive {
          if driver.uuid != trip?.driverUid {
            return
          }
          
          if let pickupCoordinates = trip?.pickupCoordinates,
             let driverCoordinates = driver.location?.coordinate {
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
      .store(in: &cancellables)
  }
  
  func uploadTrip() {
    guard let pickupCoordinate = LocationHandler.shared.location?.coordinate else { return }
    guard let destinationCoordinate = selectedPlacemark?.coordinate else { return }
    
    isLoading = true
    loadingMessage = "Finding your ride now.."
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await diContainer.passengerService.uploadTrip(pickupCoordinate: pickupCoordinate, destinationCoordinate: destinationCoordinate)
      
      self.rideActionViewState = .notAvailable
    }
  }
  
  func driverObserveTrip() {
    diContainer.driverService.tripPublisher()
      .sink { _ in } receiveValue: { [weak self] trip in
        guard let self = self else { return }
        
        self.showPickupView = trip.state == .requested
        self.trip = trip
        
        if trip.state == .accepted {
          driverAcceptTrip()
          
          guard let location = LocationHandler.shared.location else { return }
          
          Task(handlingError: self) {
            try await self.diContainer.driverService.updateDriverLocation(location: location)
          }
        }
      }
      .store(in: &cancellables)
  }
  
  func observeCancelledTrip(trip: Trip) {
    diContainer.driverService.tripCancelPublisher(trip: trip)
      .sink { _ in } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        
        rideActionViewState = .notAvailable
        selectedPlacemark = nil
        routeCoordinates = nil
        zoomToCurrentUser()
        showAlertOnUI(message: "The passenger has decided to cancel this ride. Press OK to continue")
      }
      .store(in: &cancellables)
  }
  
  func driverAcceptTrip() {
    guard trip != nil else { return }
    
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      try await diContainer.driverService.acceptTrip(trip: trip!)
      
      self.trip?.state = .accepted
      self.trip?.driverUid = Auth.auth().currentUser?.uid
      
      self.observeCancelledTrip(trip: trip!)
      
      self.setCustomRegion(withAnnotationType: .pickup, withCoordinates: trip!.pickupCoordinates)
      
      let pickupCoordinates = trip!.pickupCoordinates!
      let location = CLLocation(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude)
      
      let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
      
      if let placeMark = placemarks.first {
        let mapKitPlacemark = MKPlacemark(placemark: placeMark)
        
        Task(handlingError: self) { [weak self] in
          guard let self = self else { return }
          let passenger = try await diContainer.userService.fetchUserData(userId: trip!.passengerUid)
          self.rideActionUser = passenger
          self.selectedPlacemark = mapKitPlacemark
          self.rideActionViewState = .tripAccepted
          self.calculateRoute(to: mapKitPlacemark)
          
          if let driverLocation = LocationHandler.shared.location {
            let distance = driverLocation.distance(from: location)
            if distance < 100 {
              handleDriverArrived(for: trip!)
            }
          }
        }
      }
    }
  }
  
  private func handleDriverArrived(for trip: Trip) {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await diContainer.driverService.updateTripState(trip: trip, state: .driverArrived)
      rideActionViewState = .pickupPassenger
    }
  }
  
  func showConfirmCancelTrip() {
    let actionButton = AppAlert.ActionButton(
      title: "I'm sure",
      action: { [weak self] in
        guard let self = self else { return }
        cancelTrip()
      })
    
    appAlert = AppAlert(title: "Cancel Trip?",
                        message: "Are you sure you want to cancel current trip?",
                        actionButton: actionButton)
  }
  
  func cancelTrip() {
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      try await diContainer.passengerService.deleteTrip()
      
      self.trip?.state = .denied
      self.trip?.driverUid = nil
      self.clearRouteAndLocationSelection()
      self.fetchDrivers()
    }
  }
  
  func startTrip() {
    guard let trip = self.trip else { return }
    
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      guard
        let destinationCoordinates = trip.destinationCoordinates,
        let driverCoordinates = LocationHandler.shared.location?.coordinate
      else { return }
      
      try await self.diContainer.driverService.updateTripState(trip: trip, state: .inProgress)
      
      let location = CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude)
      let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
      
      if let placeMark = placemarks.first {
        let mapKitPlacemark = MKPlacemark(placemark: placeMark)
        self.rideActionViewState = .tripInProgress
        self.selectedPlacemark = mapKitPlacemark
        self.calculateRoute(to: mapKitPlacemark)
        self.setCustomRegion(withAnnotationType: .destination, withCoordinates: destinationCoordinates)
        self.zoomToFit(coordinates: [driverCoordinates, destinationCoordinates])
      }
    }
  }
  
  func dropOff() {
    guard let trip = self.trip else { return }
    
    isLoading = true
    self.trip?.state = .completed
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      try await self.diContainer.driverService.updateTripState(trip: trip, state: .completed)
      rideActionViewState = .notAvailable
      selectedPlacemark = nil
      routeCoordinates = nil
      zoomToCurrentUser()
    }
  }
  
  func removeAllListener() {
    self.diContainer.driverService.removeAllListener()
    self.diContainer.passengerService.removeAllListeners()
  }
  
  //MARK: - Location Handling
  
  func enableLocationServices() {
    LocationHandler.shared.enableLocationServices()
  }
  
  func updateLocations(location: CLLocation) {
    self.cameraPosition = .region(
      MKCoordinateRegion(
        center: location.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
    )
    
    if user?.accountType == .driver {
      Task(handlingError: self) {
        try await self.diContainer.driverService.updateDriverLocation(location: location)
      }
    } else {
      self.fetchDrivers()
    }
  }
  
  func driverDidEnterRegion(region: CLRegion) {
    guard let trip = self.trip else { return }
    
    let regionId = region.identifier
    if regionId == AnnotationType.pickup.rawValue {
      handleDriverArrived(for: trip)
    }
    
    if regionId == AnnotationType.destination.rawValue {
      Task(handlingError: self) { [weak self] in
        guard let self = self else { return }
        try await diContainer.driverService.updateTripState(trip: trip, state: .arrivedAtDestination)
        
        rideActionViewState = .endTrip
      }
    }
  }
  
  //MARK: - Location Input & Search Management
  
  func showLocationInputView() {
    inputViewState = .active
    updateSavedLocation()
  }
  
  func updateSavedLocation() {
    savedPlacemarks = []
    
    if let homeAddress = user?.homeLocation {
      geocodeAddressString(address: homeAddress)
    }
    
    if let workAddress = user?.workLocation {
      geocodeAddressString(address: workAddress)
    }
  }
  
  private func geocodeAddressString(address: String) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
      guard let self = self else { return }
      if let error = error {
        print("DEBUG - Geocoding error: \(error.localizedDescription)")
        return
      }
      
      if let placemark = placemarks?.first {
        savedPlacemarks.append(MKPlacemark(placemark: placemark))
      }
    }
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
  
  func onSearchTextChange() {
    debounceTimer?.invalidate()
    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
      DispatchQueue.main.async {
        Task(handlingError: self) { [weak self] in
          guard let self = self else { return }
          try await searchPlacemarks()
        }
      }
    })
  }
  
  func searchPlacemarks() async throws {
    self.placemarks = []
    let query = searchText
    
    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    if let region = cameraPosition.region {
      request.region = region
    }
    
    let searchTask = MKLocalSearch(request: request)
    let response = try await searchTask.start()
    
    response.mapItems.forEach { item in
      self.placemarks.append(item.placemark)
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
