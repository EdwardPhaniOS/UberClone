//
//  SettingsView.swift
//  UberClone
//
//  Created by Vinh Phan on 8/11/25.
//

import SwiftUI

struct SettingsView: View {
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.diContainer) var diContainer: DIContainer
  @StateObject var viewModel: SettingsViewVM
  
  init(user: User?) {
    _viewModel = StateObject(wrappedValue: SettingsViewVM(user: user))
  }
  
  var body: some View {
    NavigationView {
      VStack() {
        HStack {
          ZStack {
            RoundedRectangle(cornerRadius: 36)
              .frame(width: 72, height: 72)
              .foregroundStyle(.gray)
            Image(systemName: "person")
              .foregroundStyle(.white)
              .font(.system(size: 24))
          }
          .padding(.top)
          .padding(.leading)
          
          VStack(alignment: .leading) {
            Text(viewModel.userName)
              .foregroundStyle(.black)
              .font(.title3)
            Text(verbatim: viewModel.userEmail)
              .foregroundStyle(.gray)
              .font(.subheadline)
          }
          .padding(.leading, 4)
          .padding(.top, 12)
          
          Spacer()
        }
        
        VStack(spacing: 0) {
          Text("Favorites")
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(uiColor: AppColors.backgroundColor))
            .foregroundColor(.white)
            .listRowInsets(EdgeInsets())
          
          List {
            Section {
              ForEach(viewModel.locationTypeList, id: \.self) { type in
                Button {
                  viewModel.selectedLocationType = type
                  viewModel.showAddLocation = true
                } label: {
                  VStack(alignment: .leading) {
                    Text(viewModel.getLocationTitle(type: type))
                      .foregroundStyle(.black)
                      .font(.title3)
                    Text(viewModel.getLocationSubTitle(type: type))
                      .foregroundStyle(.gray)
                      .font(.subheadline)
                  }
                }
              }
            }
          }
          .listStyle(.plain)
        }
      }
      .navigationTitle("Settings")
      .toolbarBackground(Color(uiColor: AppColors.backgroundColor), for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("", systemImage: "xmark") {
            dismiss()
          }
          .foregroundStyle(.white)
        }
      }
      .fullScreenCover(isPresented: $viewModel.showAddLocation) {
        AddLocationView(diContainer: diContainer, locationType: viewModel.selectedLocationType) { type, address in
          viewModel.updateSavedLocation(type: type, address: address)
        }
      }
    }
    
   
  }
}

#Preview {
  SettingsView(user: User.mock)
}

