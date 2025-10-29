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

  @StateObject var authViewModel: AuthViewModel
  @StateObject var homeViewModel: HomeView.ViewModel
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  init() {
    let authVM = AuthViewModel()
    _authViewModel = StateObject(wrappedValue: authVM)
    _homeViewModel = StateObject(wrappedValue: HomeView.ViewModel(authViewModel: authVM))
   }

  var body: some Scene {
    WindowGroup {
      HomeView(viewModel: homeViewModel)
    }.environmentObject(authViewModel)
  }
}
