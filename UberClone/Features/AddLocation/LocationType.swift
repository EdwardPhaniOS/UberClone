//
//  FavoriteLocationType.swift
//  UberClone
//
//  Created by Vinh Phan on 10/11/25.
//

import Foundation

enum LocationType: Int, CaseIterable, CustomStringConvertible {
  case home
  case work
  
  var description: String {
    switch self {
    case .home:
      return "Home"
    case .work:
      return "Work"
    }
  }
  
  var subTitle: String {
    switch self {
    case .home:
      return "Add Home"
    case .work:
      return "Add Work"
    }
  }
}
