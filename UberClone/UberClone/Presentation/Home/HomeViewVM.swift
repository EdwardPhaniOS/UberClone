//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import MapKit
import FirebaseAuth
import CoreLocation
import Combine

@MainActor
class HomeViewVM: NSObject, ObservableObject, ErrorDisplayable {
  
  enum InputViewState: Equatable {
    case hidden
    case inactive
    case active
    case didSelectDestination
  }
  
  enum AnnotationType: String {
    case pickup
    case destination
  }
  
  //MARK: - Variables
  @AppStorage("passengerId") private var passengerId: String = ""
  
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
  @Published var inputViewState: InputViewState = .hidden
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
  
  private let passengerService: PassengerService
  private let driverService: DriverService
  private let userService: UserService
  
  //MARK: - Init
  
  init(user: User?,
       passengerService: PassengerService = Inject().wrappedValue,
       driverService: DriverService = Inject().wrappedValue,
       userService: UserService = Inject().wrappedValue) {
    self.user = user
    self.passengerService = passengerService
    self.driverService = driverService
    self.userService = userService
    super.init()
    
    configureInitialViewState()
    setSubscribers()
  }
  
  // MARK: - UI State & Alerts
  func configureInitialViewState() {
    guard let user = user else { return }
    
    self.driverAnnotations = []
    if user.accountType == .passenger {
      inputViewState = .inactive
    } else {
      inputViewState = .hidden
    }
  }
  
  func showAlertOnUI(message: String) {
    appAlert = AppAlert(title: "", message: message)
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
}

//MARK: Subscribers & Trip Management
extension HomeViewVM {
  
  private func setSubscribers() {
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
  
  private func passengerObserverCurrentTrip() {
    passengerService.observeCurrentTrip()
      .sink { _ in } receiveValue: { [weak self] trip in
        guard let self = self else { return }
        self.trip = trip
        guard let state = trip.state else { return }
        
        switch state {
        case .requested:
          break

        case .denied:
          self.handleTripDenied()
          
        case .accepted, .driverArrived, .inProgress:
          self.handleTripProgress(trip: trip)
          
        case .arrivedAtDestination:
          self.rideActionViewState = .endTrip
          self.inputViewState = .didSelectDestination
          
        case .completed:
          self.handleTripCompleted()
          
        @unknown default:
          break
        }
      }
      .store(in: &cancellables)
  }
  
  private func fetchDrivers() {
    guard let location = LocationHandler.shared.location else { return }
    
    passengerService.fetchDrivers(location: location)
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
        
        let driverAnnotation = DriverAnnotation(uuid: driver.uuid, coordinate: coordinate)
        
        if let index = self.driverAnnotations.firstIndex(where: { $0.uuid == driverAnnotation.uuid }) {
          self.driverAnnotations[index] = driverAnnotation
        } else {
          self.driverAnnotations.append(driverAnnotation)
        }
      }
      .store(in: &cancellables)
  }
  
  func driverObserveTrip() {
    driverService.tripPublisher()
      .sink { _ in } receiveValue: { [weak self] trip in
        guard let self = self else { return }
        
        guard (passengerId.isEmpty && trip.state == .requested)
                || passengerId == trip.passengerUid
        else { return }
        
        self.trip = trip
        handleTripStateForDriver(trip: trip)
        observeCancelledTrip(trip: trip)
      }
      .store(in: &cancellables)
  }
  
  private func observeCancelledTrip(trip: Trip) {
    driverService.tripCancelPublisher(trip: trip)
      .sink { _ in } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        
        passengerId = ""
        
        guard trip.state != .denied else { return }
        
        rideActionViewState = .notAvailable
        selectedPlacemark = nil
        routeCoordinates = nil
        zoomToCurrentUser()
        showAlertOnUI(message: "The passenger has decided to cancel this ride. Press OK to continue")
      }
      .store(in: &cancellables)
  }
  
  private func handleTripDenied() {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await passengerService.deleteTrip()
      self.clearRouteAndLocationSelection()
      self.fetchDrivers()
      self.isLoading = false
      self.showAlertOnUI(message: "Trip was denied")
    }
  }
  
  private func handleTripProgress(trip: Trip) {
    self.isLoading = false
    if let driverUid = trip.driverUid,
       let selectedDriver = driverAnnotations.first(where: { $0.uuid == driverUid }) {
      driverAnnotations = [selectedDriver]
      zoomToFit(coordinates: [selectedDriver.coordinate, trip.pickupCoordinates])
    }
    switch trip.state {
    case .accepted:
      self.rideActionViewState = .tripAccepted
    case .driverArrived:
      self.rideActionViewState = .driverArrived
    case .inProgress:
      self.rideActionViewState = .tripInProgress
    default:
      break
    }
    
    self.inputViewState = .didSelectDestination
    if selectedPlacemark == nil {
      Task(handlingError: self) { [weak self] in
        guard let self = self else { return }
        try await updateSelectedPlacemark(coordinates: trip.destinationCoordinates)
      }
    }
    
    if rideActionUser == nil {
      getDriverInfo()
      calculateRoute(to: trip.destinationCoordinates)
    }
  }
  
  private func handleTripCompleted() {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await passengerService.deleteTrip()
      self.clearRouteAndLocationSelection()
      self.fetchDrivers()
      self.showAlertOnUI(message: "Trip Completed")
    }
  }
  
  func handleTripStateForDriver(trip: Trip) {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      guard let state = trip.state else { return }
      
      switch state {
      case .denied:
        break
        
      case .requested:
        self.showPickupView = true
        
      case .accepted:
        showRouteToPassenger()
        
      case .driverArrived:
        rideActionViewState = .pickupPassenger
        
      case .inProgress:
        guard let destinationCoordinates = trip.destinationCoordinates,
              let driverCoordinates = LocationHandler.shared.location?.coordinate
        else { return }
        
        try await updateSelectedPlacemark(coordinates: destinationCoordinates)
        
        self.rideActionViewState = .tripInProgress
        self.calculateRoute(to: destinationCoordinates)
        self.setCustomRegion(withAnnotationType: .destination, withCoordinates: destinationCoordinates)
        self.zoomToFit(coordinates: [driverCoordinates, destinationCoordinates])
        
      case .arrivedAtDestination:
        rideActionViewState = .endTrip
        
      case .completed:
        rideActionViewState = .notAvailable
        selectedPlacemark = nil
        routeCoordinates = nil
        zoomToCurrentUser()
        
      @unknown default:
        break
      }
    }
  }
  
  private func getDriverInfo() {
    guard let driverUid = trip?.driverUid else { return }
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      let driver = try await userService.fetchUserData(userId: driverUid)
      self.rideActionUser = driver
    }
  }
  
  func uploadTrip() {
    guard let pickupCoordinate = LocationHandler.shared.location?.coordinate else { return }
    guard let destinationCoordinate = selectedPlacemark?.coordinate else { return }
    
    isLoading = true
    loadingMessage = "Finding your ride now.."
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await passengerService.uploadTrip(pickupCoordinate: pickupCoordinate, destinationCoordinate: destinationCoordinate)
      
      self.rideActionViewState = .notAvailable
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
      
      try await self.driverService.updateTripState(trip: trip, state: .inProgress)
      trip.state = .inProgress
      
      try await updateSelectedPlacemark(coordinates: destinationCoordinates)
      
      self.rideActionViewState = .tripInProgress
      self.calculateRoute(to: destinationCoordinates)
      self.setCustomRegion(withAnnotationType: .destination, withCoordinates: destinationCoordinates)
      self.zoomToFit(coordinates: [driverCoordinates, destinationCoordinates])
    }
  }
  
  func cancelTrip() {
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      try await passengerService.deleteTrip()
      
      self.trip = nil
      self.clearRouteAndLocationSelection()
      self.fetchDrivers()
    }
  }
  
  func dropOff() {
    guard let trip = self.trip else { return }
    
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      try await self.driverService.updateTripState(trip: trip, state: .completed)
      trip.state = .completed
      rideActionViewState = .notAvailable
      selectedPlacemark = nil
      routeCoordinates = nil
      passengerId = ""
      zoomToCurrentUser()
    }
  }
  
  func removeAllListener() {
    self.driverService.removeAllListener()
    self.passengerService.removeAllListeners()
  }
  
}

//MARK: Location Input & Search Management
extension HomeViewVM {
  
  func showLocationInputView() {
    inputViewState = .active
    updateSavedLocation()
  }
  
  private func updateSavedLocation() {
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
  
  private func clearRouteAndLocationSelection() {
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
  
  private func searchPlacemarks() async throws {
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
    inputViewState = .didSelectDestination
    rideActionViewState = .requestRide
    calculateRoute(to: placemark.coordinate)
  }
}

//MARK: - Location Handling
private extension HomeViewVM {
  func updateLocations(location: CLLocation) {
    self.cameraPosition = .region(
      MKCoordinateRegion(
        center: location.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
    )
    
    if user?.accountType == .driver {
      Task(handlingError: self) {
        try await self.driverService.updateDriverLocation(location: location)
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
        try await driverService.updateTripState(trip: trip, state: .arrivedAtDestination)
        trip.state = .arrivedAtDestination
        rideActionViewState = .endTrip
      }
    }
  }
  
  func handleDriverArrived(for trip: Trip) {
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      try await driverService.updateTripState(trip: trip, state: .driverArrived)
      rideActionViewState = .pickupPassenger
    }
  }
}

//MARK: - Map & Route Handling
extension HomeViewVM {
  private func calculateRoute(to destination: CLLocationCoordinate2D) {
    guard let currentCoordinate = LocationHandler.shared.location?.coordinate else { return }
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentCoordinate))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
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
  
  private func zoomToFit(coordinates: [CLLocationCoordinate2D]) {
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
  
  private func zoomToCurrentUser() {
    guard let currentCoordinate = LocationHandler.shared.location?.coordinate else { return }
    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    withAnimation(.easeInOut(duration: 0.3)) {
      self.cameraPosition = .region(MKCoordinateRegion(center: currentCoordinate, span: span))
    }
  }
  
  private func setCustomRegion(withAnnotationType type: AnnotationType, withCoordinates coordinates: CLLocationCoordinate2D) {
    let region = CLCircularRegion(center: coordinates, radius: 100, identifier: type.rawValue)
    LocationHandler.shared.locationManager.startMonitoring(for: region)
  }
  
  func showRouteToPassenger() {
    guard trip != nil else { return }
    
    isLoading = true
    
    Task(handlingError: self) { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      
      let pickupCoordinates = trip!.pickupCoordinates!
      try await updateSelectedPlacemark(coordinates: pickupCoordinates)
      calculateRoute(to: pickupCoordinates)
      
      rideActionUser = try await userService.fetchUserData(userId: trip!.passengerUid)
      passengerId = trip!.passengerUid
      rideActionViewState = .tripAccepted
     
      setCustomRegion(withAnnotationType: .pickup, withCoordinates: trip!.pickupCoordinates)
      
      let pickupLocation = CLLocation(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude)
      
      if let driverLocation = LocationHandler.shared.location {
        let distance = driverLocation.distance(from: pickupLocation)
        if distance < 100 {
          handleDriverArrived(for: trip!)
        }
      }
    }
  }
  
  func updateSelectedPlacemark(coordinates: CLLocationCoordinate2D) async throws {
    let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    
    let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
    
    if let placeMark = placemarks.first {
      let mapKitPlacemark = MKPlacemark(placemark: placeMark)
      self.selectedPlacemark = mapKitPlacemark
    }
  }
  
}
