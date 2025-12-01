//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct PrintFileOnAppearModifier: ViewModifier {

  let fileURL: String

  init(fileURL: String = #file) {
    self.fileURL = fileURL
  }

  func body(content: Content) -> some View {
  #if DEBUG
    content.onAppear {
      let fileName = URL(fileURLWithPath: fileURL).lastPathComponent
      print("File: \(fileName) loaded")
    }
  #endif
  }
}

extension View {
  func printFileOnAppear(fileURL: String = #file) -> some View {
    self.modifier(PrintFileOnAppearModifier(fileURL: fileURL))
  }
}
