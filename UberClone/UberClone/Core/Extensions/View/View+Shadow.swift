//
//  View+Shadow.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func shadow(_ appShadow: AppShadow) -> some View {
    self.shadow(color: appShadow.color, radius: appShadow.radius, x: appShadow.x, y: appShadow.y)
  }
}

struct AppShadow {
  let color: Color
  let radius: CGFloat
  let x: CGFloat
  let y: CGFloat
}

extension AppShadow {
  static let none = AppShadow(color: .black.opacity(0.0), radius: 0, x: 0, y: 0)
  static var light: Self = .init(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
  static var regular: Self = .init(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
  static var heavy: Self = .init(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
  static var top: Self = .init(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
}
