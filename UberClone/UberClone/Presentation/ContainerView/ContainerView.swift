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
  @State var showConfirmLogout: Bool = false
  @State var showSettings: Bool = false
  
  init(diContainer: DIContainer) {
    _viewModel = StateObject(wrappedValue: ContainerViewVM(diContainer: diContainer))
  }
  
  var body: some View {
    ZStack {
      HomeView(diContainer: viewModel.diContainer, user: viewModel.user) {
        isMenuOpen = !isMenuOpen
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
            showConfirmLogout = true
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
    .fullScreenCover(isPresented: $viewModel.showLogin) {
      NavigationStack {
        LoginView(diContainer: viewModel.diContainer)
      }
    }
    .fullScreenCover(isPresented: $showSettings, content: {
      SettingsView(user: viewModel.user)
    })
    
    .actionSheet(isPresented: $showConfirmLogout) {
      ActionSheet(title: Text("Are your sure you want to logout?"), buttons: [
        .destructive(Text("Logout"), action: {
          viewModel.signOut()
        }),
        .cancel()
      ])
    }
    .statusBarHidden(isMenuOpen)
    .showLoading(isLoading: viewModel.isLoading)
  }
}

#Preview {
  ContainerView(diContainer: .mock)
}
