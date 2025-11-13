//
//  SideMenuView.swift
//  UberClone
//
//  Created by Vinh Phan on 4/11/25.
//

import SwiftUI

enum MenuOption: Int, CaseIterable, CustomStringConvertible {
  case yourTrips
  case settings
  case logout
  
  var description: String {
    switch self {
    case .yourTrips: return "Your Trips"
    case .settings: return "Settings"
    case .logout: return "Log Out"
    }
  }
}

struct SideMenuView: View {
  
  var user: User?
  var selectedOptionCallback: ((MenuOption) -> Void)? = nil

  init(user: User?, selectedOptionCallback: ((MenuOption) -> Void)? = nil) {
    self.user = user
    self.selectedOptionCallback = selectedOptionCallback
  }
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, content: {
        ZStack {
          Rectangle()
            .frame(height: 200)
            .foregroundStyle(Color.appTheme.viewBackground)
          
          HStack {
            ZStack {
              RoundedRectangle(cornerRadius: 36)
                .frame(width: 72, height: 72)
                .foregroundStyle(Color.appTheme.accent)
              Text(user?.firstInitial ?? "")
                .foregroundStyle(Color.appTheme.accentContrastText)
                .font(.system(size: 36))
            }
            .padding()
            VStack(alignment: .leading) {
              Text(user?.fullName ?? "")
                .foregroundStyle(Color.appTheme.text)
                .font(.title3)
              Text(verbatim: user?.email ?? "")
                .foregroundStyle(Color.appTheme.info)
                .font(.subheadline)
            }
            Spacer()
          }
          .padding(.top, 48)
        }
        
        ForEach(MenuOption.allCases, id: \.self) { option in
          Text(option.description)
            .padding()
            .onTapGesture {
              selectedOptionCallback?(option)
            }
        }
        Spacer()
      })
      .ignoresSafeArea(edges: [.top])
      .frame(maxWidth: 280, alignment: .leading)
      .background(Color.appTheme.cellBackground)
      
      Spacer()
    }
  }
 
}

#Preview {
  SideMenuView(user: User.mock, selectedOptionCallback: nil)
}
