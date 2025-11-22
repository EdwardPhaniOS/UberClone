//
//  AddLocationViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 10/11/25.
//

import Foundation
import MapKit

@MainActor
class AddLocationViewVM: NSObject, ObservableObject, ErrorDisplayable {
  
  @Published var locations: [MKPlacemark] = []
  @Published var searchText = ""
  @Published var isLoading = false
  @Published var error: Error?
  @Published var appAlert: AppAlert?
  
  var locationType: LocationType
  var region: MKCoordinateRegion?
  var debounceTimer: Timer?
  
  private let passengerService: PassengerService
  
  init(locationType: LocationType, passengerService: PassengerService = Inject().wrappedValue) {
    self.locationType = locationType
    self.passengerService = passengerService
    
    if let currentLocation = LocationHandler.shared.location {
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      self.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
    }
  }
  
  func onSeachTextChange() {
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
    self.locations = []
    let query = searchText
    
    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    if let region = region {
      request.region = region
    }
    
    let searchTask = MKLocalSearch(request: request)
    let response = try await searchTask.start()
    
    response.mapItems.forEach { item in
      self.locations.append(item.placemark)
    }
  }
  
  func saveLocation(location: MKPlacemark, completion: @escaping () -> Void) {
    isLoading = true
    
    Task(handlingError: self, operation: { [weak self] in
      guard let self = self else { return }
      defer { isLoading = false }
      try await passengerService.saveLocation(type: locationType, location: location.address)
      completion()
    })
  }
}
