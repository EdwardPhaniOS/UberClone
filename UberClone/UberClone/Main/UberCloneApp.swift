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

  @StateObject var authViewModel = AuthViewModel()
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      HomeView(viewModel: .init(authViewModel: authViewModel))
        .environmentObject(authViewModel)
    }
  }
}
