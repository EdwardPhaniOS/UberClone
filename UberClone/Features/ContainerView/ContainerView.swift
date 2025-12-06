//
//  ContainerView.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import SwiftUI

struct ContainerView: View {
  
  @StateObject var viewModel: ContainerViewVM
  @State var isMenuOpen: Bool = false
  @State var showSettings: Bool = false
  
  init() {
    _viewModel = StateObject(wrappedValue: ContainerViewVM())
  }
  
  var body: some View {
    ZStack {
      if let user = viewModel.user {
        HomeView(user: user) {
          isMenuOpen = !isMenuOpen
        }
      }
      
      if isMenuOpen {
        Color.black.opacity(0.3)
          .ignoresSafeArea()
          .onTapGesture {
            isMenuOpen = false
          }
        SideMenuView(user: viewModel.user, selectedOptionCallback: { option in
          isMenuOpen = false
          
          if option == .logout {
            viewModel.showConfirmSignOut()
          } else if option == .settings {
            showSettings = true
          }
        })
        .transition(.move(edge: .leading))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
    .onAppear {
      viewModel.enableLocationServices()
      viewModel.setUpSubcription()
    }
    .onChange(of: viewModel.appState, { _, newValue in
      if newValue == .app {
        viewModel.fetchUserData()
      }
    })
    .printFileOnAppear()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
    .statusBarHidden(isMenuOpen)
    .showError(item: $viewModel.error)
    .showAlert(item: $viewModel.appAlert)
    .showLoading(isLoading: viewModel.isLoading)
    .fullScreenCover(isPresented: $viewModel.showLogin) {
      NavigationStack {
        LoginView()
      }
    }
    .fullScreenCover(isPresented: $showSettings, content: {
      NavigationStack {
        SettingsView(user: viewModel.user)
      }
    })
  }
}

#Preview {
  ContainerView()
}
