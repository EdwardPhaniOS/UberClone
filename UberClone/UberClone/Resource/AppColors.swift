// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import UIKit

struct AppColors {
  static let backgroundColor = UIColor(hex: "#191919")
  static let mainBlueTint = UIColor(hex: "#119AED")
  static let outlineStrokeColor = UIColor(hex: "#EA2E6F")
  static let trackStrokeColor = UIColor(hex: "#381931")
  static let pulsatingFillColor = UIColor(hex: "#561E3F")
}

extension UIColor {
  convenience init(hex: String) {
      var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
      hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

      var rgb: UInt64 = 0
      Scanner(string: hexSanitized).scanHexInt64(&rgb)

      let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
      let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
      let b = CGFloat(rgb & 0x0000FF) / 255

      self.init(red: r, green: g, blue: b, alpha: 1)
  }
}
