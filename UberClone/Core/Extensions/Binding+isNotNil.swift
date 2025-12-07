//
//  Binding+isNotNil.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import SwiftUI

extension Binding {
  func isNotNil<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    Binding<Bool>(get: {
      wrappedValue != nil
    }, set: { newValue in
      if newValue == false {
        wrappedValue = nil
      }
    })
  }
}
