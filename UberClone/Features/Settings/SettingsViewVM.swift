//
//  SettingsViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 10/11/25.
//

import Foundation

@MainActor
class SettingsViewVM: NSObject, ObservableObject {
  @Published var showAddLocation: Bool = false
  @Published var user: User?
  
  var selectedLocationType: LocationType = .home
  
  var locationTypeList: [LocationType] {
    return LocationType.allCases
  }
  
  var userName: String {
    return user?.fullName ?? ""
  }
  
  var userEmail: String {
    return user?.email ?? ""
  }
  
  init(user: User?) {
    self.user = user
  }
  
  func getLocationTitle(type: LocationType) -> String {
    return type.description
  }
  
  func getLocationSubTitle(type: LocationType) -> String {
    switch type {
    case .home:
      return user?.homeLocation ?? type.subTitle
    case .work:
      return user?.workLocation ?? type.subTitle
    }
  }
  
  func selectLocationType(type: LocationType) {
    selectedLocationType = type
    showAddLocation = true
  }
  
  func updateSavedLocation(type: LocationType, address: String) {
    switch type {
    case .home:
      user?.homeLocation = address
    case .work:
      user?.workLocation = address
    }
  }
}
