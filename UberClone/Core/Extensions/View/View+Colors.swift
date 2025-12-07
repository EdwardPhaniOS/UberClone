//
//  View+Colors.swift
//  UberClone
//
//  Created by Vinh Phan on 12/11/25.
//

import SwiftUI

extension Color {
  static var appTheme: AppColorTheme = defaultAppTheme
}

extension Color {
  static var defaultAppTheme: AppColorTheme = AppColorTheme(
    accent: .accent,
    alternateAccent: .alternateAccent,
    viewBackground: .viewBackground,
    cellBackground: .cellBackground,
    text: .text,
    secondaryText: .secondaryText,
    alternateText: .alternateText,
    accentContrastText: .accentContrastText,
    primaryAction: .primaryAction,
    neutralAction: .neutralAction,
    destructive: .destructive,
    success: .success,
    warning: .warning,
    info: .info,
    error: .error,
    inProgress: .inProgress,
    divider: .divider,
    miscellaneous: .miscellaneous)
}

struct AppColorTheme {
  let accent: Color
  let alternateAccent: Color
  let viewBackground: Color
  let cellBackground: Color
  let text: Color
  let secondaryText: Color
  let alternateText: Color
  let accentContrastText: Color
  let primaryAction: Color
  let neutralAction: Color
  let destructive: Color
  let success: Color
  let warning: Color
  let info: Color
  let error: Color
  let inProgress: Color
  let divider: Color
  let miscellaneous: Color
}

private struct Preview: View {
  var body: some View {
    VStack {
      VStack {
        Text("title")
          .foregroundStyle(Color.appTheme.text)
        Text("Subtitle")
          .foregroundStyle(Color.appTheme.secondaryText)
      }
      
      Divider()
        .background(Color.appTheme.divider)
        .padding(.horizontal)
      
      Button(action: {}, label: {
        Text("Get Started")
          .padding()
          .background(Color.appTheme.accent)
          .cornerRadius(8)
          .foregroundStyle(Color.appTheme.accentContrastText)
      })
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appTheme.viewBackground)
  }
}

#Preview("Light Mode") {
  Preview()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
  Preview()
    .preferredColorScheme(.dark)
}
