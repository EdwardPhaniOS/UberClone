//
//  AddLocationViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 10/11/25.
//

import Foundation
import MapKit

@MainActor
class AddLocationViewVM: NSObject, ObservableObject {
  
  @Published var locations: [MKPlacemark] = []
  @Published var searchText = ""
  @Published var isLoading = false
  @Published var showAlert = false
  @Published var loadingMessage = ""
  @Published var alertMessage = ""
  
  var diContainer: DIContainer
  var locationType: LocationType
  var region: MKCoordinateRegion?
  var debounceTimer: Timer?
  
  init(diContainer: DIContainer, locationType: LocationType) {
    self.locationType = locationType
    self.diContainer = diContainer
    
    if let currentLocation = LocationHandler.shared.location {
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      self.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
    }
  }
  
  func onSeachTextChange() {
    debounceTimer?.invalidate()
    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
      guard let self = self else { return }
      
      Task { @MainActor in
        self.searchPlacemarks()
      }
    })
  }
  
  func searchPlacemarks() {
    self.locations = []
    let query = searchText
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    if let region = region {
      request.region = region
    }
    
    let searchTask = MKLocalSearch(request: request)
    searchTask.start { [weak self] response, error in
      guard let self = self else { return }
      guard let response = response else { return }
      
      response.mapItems.forEach { item in
        Task { @MainActor in
          self.locations.append(item.placemark)
        }
      }
    }
  }
  
  func saveLocation(location: MKPlacemark, completion: @escaping () -> Void) {
    isLoading = true
    diContainer.passengerService.saveLocation(type: locationType, location: location.address) { [weak self] error, _ in
      guard let self = self else { return }
      self.isLoading = false
      
      if let err = error {
        self.showAlert = true
        self.alertMessage = err.localizedDescription
      }
      
      completion()
    }
  }
}
