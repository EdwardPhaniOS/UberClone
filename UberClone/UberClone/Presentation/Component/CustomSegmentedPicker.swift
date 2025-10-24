// Created on 10/21/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import SwiftUI

struct CustomSegmentedPicker: UIViewRepresentable {

  @Binding var selection: Int
  let items: [String]
  var tintColor: UIColor = .white
  var textColorInNormalState: UIColor = .white
  var textColorInSelectedState: UIColor = .black
  var font: UIFont = .systemFont(ofSize: 16)

  func makeUIView(context: Context) -> UISegmentedControl {
    let control = UISegmentedControl(items: items)
    control.selectedSegmentIndex = selection
    control.selectedSegmentTintColor = tintColor
    control.backgroundColor = .black
    let normalAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: textColorInNormalState,
      .font: font
    ]
    let selectedAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: textColorInSelectedState,
      .font: font
    ]
    control.setTitleTextAttributes(normalAttributes, for: .normal)
    control.setTitleTextAttributes(selectedAttributes, for: .selected)
    control.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)

    return control
  }

  func updateUIView(_ uiView: UISegmentedControl, context: Context) {
    uiView.selectedSegmentIndex = selection
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    var parent: CustomSegmentedPicker
    init(_ parent: CustomSegmentedPicker) {
      self.parent = parent
    }

    @objc func valueChanged(_ sender: UISegmentedControl) {
      parent.selection = sender.selectedSegmentIndex
    }
  }
}
