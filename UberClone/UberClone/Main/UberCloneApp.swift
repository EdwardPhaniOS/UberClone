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
  let diContainer: DIContainer = DIContainer()
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  init() {
    let authVM = AuthVM()
    _authViewModel = StateObject(wrappedValue: authVM)
    
    let homeVM = HomeViewVM(diContainer: diContainer, authViewModel: authVM)
    _homeViewVM = StateObject(wrappedValue: homeVM)
  }
  
  var body: some Scene {
    WindowGroup {
      HomeView(viewModel: homeViewVM)
    }
    .environmentObject(authViewModel)
    .environment(\.diContainer, diContainer)
  }
}
