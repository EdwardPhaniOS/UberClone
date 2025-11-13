//
//  View+CornerRadius.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func cornerRadius(_ appCornerRadius: AppCornerRadius) -> some View {
    self.clipShape(RoundedRectangle(cornerRadius: appCornerRadius.value))
  }
}

struct AppCornerRadius {
  let value: CGFloat
}

extension AppCornerRadius {
  static var overall: Self = .init(value: 8)
  static var cell: Self = .init(value: 8)
  static var button: Self = .init(value: 8)
  static var textField: Self = .init(value: 8)
}
