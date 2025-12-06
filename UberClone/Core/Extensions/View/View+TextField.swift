//
//  View+TextField.swift
//  UberClone
//
//  Created by Vinh Phan on 15/11/25.
//

import SwiftUI

extension View {
  func textFieldWithUnderline(sfSymbol: String) -> some View {
    VStack(alignment: .center, spacing: 4) {
      HStack {
        Image(systemName: sfSymbol)
          .foregroundStyle(Color.appTheme.divider)
          .frame(width: 30)
        self
      }
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(Color.appTheme.divider)
    }
  }
}
