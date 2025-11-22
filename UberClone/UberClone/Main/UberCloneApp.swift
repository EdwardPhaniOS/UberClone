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
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  init() {
    DIContainer.shared.load(modules: [
      ServiceModule()
    ])
  }
  
  var body: some Scene {
    WindowGroup {
      ContainerView()
    }
  }
}
