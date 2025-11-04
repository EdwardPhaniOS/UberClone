//
//  UberCloneApp.swift
//  UberClone
//
//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI
import UIKit

@main
struct UberCloneApp: App {

  @StateObject var authViewModel: AuthVM
  @StateObject var homeViewVM: HomeViewVM
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  init() {
    let authVM = AuthVM()
    _authViewModel = StateObject(wrappedValue: authVM)
    _homeViewVM = StateObject(wrappedValue: HomeViewVM(authViewModel: authVM))
   }

  var body: some Scene {
    WindowGroup {
      HomeView(viewModel: homeViewVM)
    }.environmentObject(authViewModel)
  }
}
