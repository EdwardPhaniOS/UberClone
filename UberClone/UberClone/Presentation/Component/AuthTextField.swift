//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct AuthTextField: View {

  @Binding var text: String
  var placeHolder: String = ""
  var systemImage: String
  var isSecure: Bool = false

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      HStack {
        Image(systemName: systemImage)
          .foregroundStyle(Color.appTheme.divider)
          .frame(width: 24)
        ZStack(alignment: .leading) {
          if text.isEmpty {
            Text(placeHolder)
              .foregroundStyle(.gray)
          }
          if isSecure {
            SecureField(placeHolder, text: $text)
              .foregroundStyle(Color.appTheme.text)
              .textContentType(.newPassword)
          } else {
            TextField(placeHolder, text: $text)
              .foregroundStyle(Color.appTheme.text)
          }
        }
      }
      .frame(height: 24)
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(Color.appTheme.divider)
    }
  }
}

#Preview {
  @Previewable @State var text = ""

  ZStack {
    Rectangle()
      .frame(height: 48)
    AuthTextField(text: $text, placeHolder: "Enter", systemImage: "envelope")
  }
}
