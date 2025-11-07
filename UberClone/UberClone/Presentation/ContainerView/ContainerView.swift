//
//  ContainerView.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//

import SwiftUI

struct ContainerView: View {
  
  @StateObject var viewModel: ContainerViewVM
  @StateObject var authStore: AuthStore
  @State var isMenuOpen: Bool = false
  @State var showConfirmLogout: Bool = false
  
  init() {
    let diContainer = DIContainer()
    _authStore = StateObject(wrappedValue: diContainer.authStore)
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
            withAnimation {
              isMenuOpen = false
            }
          }
        SideMenuView(user: viewModel.user, selectedOptionCallback: { option in
          
          if option == .logout {
            isMenuOpen = false
            showConfirmLogout = true
          }
        })
        .transition(.move(edge: .leading))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
    .onAppear {
      viewModel.checkIfUserIsLoggedIn()
      viewModel.enableLocationServices()
      
      if viewModel.authStore.isLoggedIn {
        viewModel.fetchUserData()
      }
    }
    .onChange(of: viewModel.authStore.isLoggedIn) { _, isLoggedIn in
      if isLoggedIn {
        viewModel.fetchUserData()
      }
    }
    .printFileOnAppear()
    .fullScreenCover(
      isPresented: Binding(
        get: { !viewModel.authStore.isLoggedIn },
        set: { _ in }
      )
    ) {
      NavigationStack {
        LoginView(diContainer: viewModel.diContainer)
      }
    }
    .actionSheet(isPresented: $showConfirmLogout) {
      ActionSheet(title: Text("Are your sure you want to logout?"), buttons: [
        .destructive(Text("Logout"), action: {
          viewModel.signOut()
        }),
        .cancel()
      ])
    }
    .statusBarHidden(isMenuOpen)
  }
}

#Preview {
  ContainerView()
}
