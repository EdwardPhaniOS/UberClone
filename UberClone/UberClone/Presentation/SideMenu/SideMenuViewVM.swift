//
//  SideMenuViewVM.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import Foundation

class SideMenuViewVM: ObservableObject {
  
  @Published var user: User?
  
  var userName: String {
    return user?.fullName ?? ""
  }
  
  var userEmail: String {
    return user?.email ?? ""
  }
  
  init(user: User?) {
    self.user = user
  }
}
