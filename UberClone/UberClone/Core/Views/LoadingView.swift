//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LoadingView: View {
  var message: String = ""

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
      ProgressView(message)
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .foregroundStyle(.white)
        .scaleEffect(1.5)
        .font(.system(size: 14))
    }
    .ignoresSafeArea()
  }
}

#Preview {
  LoadingView(message: "Loading...")
}
