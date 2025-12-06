//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LocationInputActivationView: View {

  var body: some View {
    HStack() {
      Rectangle()
        .frame(width: 8, height: 8)
        .foregroundStyle(.black)
        .padding(.leading, 12)
      Text("Where to?")
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
    .background(Color.white)
    .shadow(radius: 8)
  }
}

#Preview {
  LocationInputActivationView()
}
