//
//  SettingsView.swift
//  UberClone
//
//  Created by Vinh Phan on 8/11/25.
//

import SwiftUI

struct SettingsView: View {
  
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: SettingsViewVM
  
  init(user: User?) {
    _viewModel = StateObject(wrappedValue: SettingsViewVM(user: user))
  }
  
  var body: some View {
    VStack {
      profileView
      VStack(spacing: 0) {
        favoriteHeader
        itemListView
      }
    }
    .navigationTitle("Settings")
    .foregroundStyle(Color.appTheme.text)
    .toolbarBackground(Color.appTheme.viewBackground, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbar { toolbarContent }
    .fullScreenCover(isPresented: $viewModel.showAddLocation) {
      NavigationView {
        AddLocationView(locationType: viewModel.selectedLocationType) { type, address in
          viewModel.updateSavedLocation(type: type, address: address)
        }
      }
    }

  }
}

extension SettingsView {
  
  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button("", systemImage: "xmark") {
        dismiss()
      }
      .foregroundStyle(.white)
    }
  }
  
  var profileView: some View {
    HStack {
      ZStack {
        RoundedRectangle(cornerRadius: 36)
          .frame(width: 72, height: 72)
          .foregroundStyle(Color.appTheme.accent)
        Text(viewModel.user?.firstInitial ?? "")
          .foregroundStyle(Color.appTheme.accentContrastText)
          .font(.system(size: 36))
      }
      .padding(.top)
      .padding(.leading)
      
      VStack(alignment: .leading) {
        Text(viewModel.userName)
          .foregroundStyle(Color.appTheme.text)
          .font(.title3)
        Text(verbatim: viewModel.userEmail)
          .foregroundStyle(Color.appTheme.info)
          .font(.subheadline)
      }
      .padding(.leading, 4)
      .padding(.top, 12)
      
      Spacer()
    }
  }
  
  var favoriteHeader: some View {
    Text("Favorites")
      .font(.title2).bold()
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(Color.appTheme.viewBackground)
      .foregroundColor(Color.appTheme.text)
      .listRowInsets(EdgeInsets())
  }
  
  var itemListView: some View {
    List {
      ForEach(viewModel.locationTypeList, id: \.self) { type in
        Button {
          viewModel.selectedLocationType = type
          viewModel.showAddLocation = true
        } label: {
          VStack(alignment: .leading) {
            Text(viewModel.getLocationTitle(type: type))
              .foregroundStyle(Color.appTheme.text)
              .font(.title3)
            Text(viewModel.getLocationSubTitle(type: type))
              .foregroundStyle(Color.appTheme.info)
              .font(.subheadline)
          }
        }
      }
    }
    .listStyle(.plain)
  }
}

fileprivate struct Preview: View {
  var body: some View {
    NavigationStack {
      SettingsView(user: User.mock)
    }
  }
}

#Preview {
  Preview()
}

