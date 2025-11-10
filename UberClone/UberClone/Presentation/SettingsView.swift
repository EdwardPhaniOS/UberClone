//
//  SettingsView.swift
//  UberClone
//
//  Created by Vinh Phan on 8/11/25.
//

import SwiftUI

struct SettingsView: View {
  
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
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
            Text("Vinh")
              .foregroundStyle(.black)
              .font(.title3)
            Text(verbatim: "Vinh@nomail.com")
              .foregroundStyle(.gray)
              .font(.subheadline)
          }
          .padding(.leading, 4)
          .padding(.top, 12)
          Spacer()
        }
        List {
          Section {
            Text("Sample 1")
            Text("Sample 2")
          } header: {
            Text("Favorites")
              .font(.title2).bold()
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)
              .padding(.vertical, 8)
              .background(Color(uiColor: AppColors.backgroundColor))
              .foregroundColor(.white)
              .listRowInsets(EdgeInsets())
          }
        }
        .listStyle(.plain)
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
    }
    
   
  }
}

#Preview {
  SettingsView()
}
