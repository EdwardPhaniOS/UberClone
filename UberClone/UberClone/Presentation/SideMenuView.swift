//
//  SideMenuView.swift
//  UberClone
//
//  Created by Vinh Phan on 4/11/25.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
      HStack {
        VStack(alignment: .leading, content: {
          Text("Home")
          Text("Profile")
          Text("Settings")
          Spacer()
        })
        .frame(maxWidth: 200, alignment: .leading)
        .background(Color.gray)
        
        Spacer()
      }
    }
}

#Preview {
    SideMenuView()
}
