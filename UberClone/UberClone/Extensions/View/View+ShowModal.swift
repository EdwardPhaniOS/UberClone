//
//  View+Modal.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension View {
  func showModal(isPresenting: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) -> some View {
    self
      .modifier(ModalSupport(isPresenting: isPresenting, modalContent: content))
  }
  
  func showModal<Item>(isPresenting: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> some View) -> some View {
    self
      .modifier(ModalSupport(isPresenting: isPresenting.isNotNil(), modalContent: {
        if let wrappedValue = isPresenting.wrappedValue {
          content(wrappedValue)
        }
      }))
  }
}

struct ModalSupport<ModalContent: View>: ViewModifier {
  @Binding var isPresenting: Bool
  @ViewBuilder var modalContent: () -> ModalContent
  
  func body(content: Content) -> some View {
    ZStack {
      content
      
      if isPresenting {
        Color.black
          .opacity(0.6)
          .ignoresSafeArea()
          .transition(.opacity.animation(.smooth))
          .onTapGesture {
            isPresenting = false
          }
        
        modalContent()
      }
    }
    .animation(.easeInOut, value: isPresenting)
  }
}

fileprivate struct Preview: View {
  @State private var isPresenting: Bool = false
  @State private var item: Int? = nil
  
  var body: some View {
    VStack {
      Text("Show Modal - isPresenting")
        .primaryButton()
        .button {
          isPresenting = true
          item = nil
        }
      
      Text("Show Modal - item")
        .primaryButton()
        .button {
          isPresenting = false
          item = Int.random(in: 0...5)
        }
    }
    .padding()
    .infinityFrame()
    .background(Color.appTheme.viewBackground)
    .showModal(isPresenting: $isPresenting) {
      PreviewModalContentView()
    }
    .showModal(isPresenting: $item, content: { _ in
      PreviewModalContentView()
    })
  }
}

fileprivate struct PreviewModalContentView: View {
  var body: some View {
    Text("Modal View")
      .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/2)
      .foregroundStyle(Color.appTheme.accentContrastText)
      .background(Color.appTheme.accent)
      .cornerRadius(.overall)
  }
}

#Preview {
  Preview()
}
