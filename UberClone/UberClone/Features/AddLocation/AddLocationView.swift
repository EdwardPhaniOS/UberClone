//
//  AddLocationView.swift
//  UberClone
//
//  Created by Vinh Phan on 10/11/25.
//

import SwiftUI
import MapKit

struct AddLocationView: View {
  
  @Environment(\.dismiss) var dismiss
  @StateObject var viewModel: AddLocationViewVM
  var saveLocationCallback: ((_ type: LocationType, _ address: String) -> Void)?
  
  init(locationType: LocationType, saveLocationCallback: ((_ type: LocationType, _ address: String) -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: AddLocationViewVM(locationType: locationType))
    self.saveLocationCallback = saveLocationCallback
  }
  
  var body: some View {
    itemListView
      .searchable(text: $viewModel.searchText, prompt: "Search")
      .onChange(of: viewModel.searchText, { oldValue, newValue in
        viewModel.onSeachTextChange()
      })
      .showLoading(isLoading: viewModel.isLoading)
      .showError(item: $viewModel.error)
      .showAlert(item: $viewModel.appAlert)
      .toolbarBackground(Color.appTheme.viewBackground, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar { toolbarContent }
  }
}

extension AddLocationView {
  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button("", systemImage: "xmark", action: {
        dismiss()
      })
      .foregroundStyle(.white)
    }
  }
  
  var itemListView: some View {
    List {
      ForEach(viewModel.locations, id: \.self) { location in
        VStack(alignment: .leading) {
          Text(location.name ?? "")
            .foregroundStyle(.black)
            .font(.title3)
          Text(location.address)
            .foregroundStyle(.gray)
            .font(.subheadline)
        }
        .onTapGesture {
          viewModel.saveLocation(location: location) {
            saveLocationCallback?(viewModel.locationType, location.address)
            dismiss()
          }
        }
      }
    }
    .listStyle(.grouped)
  }
}

#Preview {
  NavigationView {
    AddLocationView(locationType: .home)
  }
}
