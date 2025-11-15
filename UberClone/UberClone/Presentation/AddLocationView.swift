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
  
  init(diContainer: DIContainer, locationType: LocationType, saveLocationCallback: ((_ type: LocationType, _ address: String) -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: AddLocationViewVM(diContainer: diContainer, locationType: locationType))
    self.saveLocationCallback = saveLocationCallback
  }
  
  var body: some View {
    NavigationView {
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
      .searchable(text: $viewModel.searchText, prompt: "Search")
      .onChange(of: viewModel.searchText, { oldValue, newValue in
        viewModel.onSeachTextChange()
      })
      .showLoading(isLoading: viewModel.isLoading)
      .alert("", isPresented: $viewModel.showAlert, actions: {
        Button("OK", role: .cancel, action: {})
      }, message: {
        Text(viewModel.alertMessage)
      })
      .toolbarBackground(Color.appTheme.viewBackground, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("", systemImage: "xmark", action: {
            dismiss()
          })
          .foregroundStyle(.white)
        }
      }
    }
  }
}

#Preview {
  AddLocationView(diContainer: .mock, locationType: .home)
}
