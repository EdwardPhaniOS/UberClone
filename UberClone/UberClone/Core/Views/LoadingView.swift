//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoadingView: View {
  var message: String = ""
  var allowUserInteraction: Bool = false

  var body: some View {
    ZStack {
      if !allowUserInteraction {
        Color.black.opacity(0.4)
      }

      VStack(spacing: 20) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: allowUserInteraction ? Color.appTheme.text : Color.white))
          .scaleEffect(2)
        Text(message)
          .foregroundColor(allowUserInteraction ? Color.appTheme.text : Color.white)
          .font(.headline)
      }
    }
    .ignoresSafeArea()
  }
}

#Preview {
  LoadingView(message: "Loading...")
}
