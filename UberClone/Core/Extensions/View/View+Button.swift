//
//  View+Button.swift
//  AllDoneCompleteCourse
//
//  Created by Raul Gutierrez Niubo on 10/10/25.
//

import SwiftUI

extension View {
  @ViewBuilder
  func button(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
    switch option {
    case .press:
      self.pressableButton(action: action)
    case .plain:
      self.plainButton(action: action)
    }
  }
  
  private func plainButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private func pressableButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
    .buttonStyle(PressableButtonStyle())
  }
}

struct PressableButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.smooth, value: configuration.isPressed)
  }
}

enum ButtonStyleOption {
  case press, plain
}

private struct Preview: View {
  var body: some View {
    VStack(spacing: 24) {
      Text("Continue")
        .primaryButton()
        .button(.press) {
          
        }
      
      Text("Continue")
        .primaryButton()
        .button {
          
        }
    }
    .padding()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
  }
}

#Preview {
  Preview()
}
