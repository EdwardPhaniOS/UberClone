//  Created by Vinh Phan on 20/10/25.
//

import SwiftUI

struct LocationRow: View {

  var title: String = "12 Tran Quang Khai"
  var desc: String = "12 Tran Quang Khai, District 1, HCM City"

    var body: some View {
      VStack(alignment: .leading) {
        Text(title)
        Text(desc)
          .foregroundStyle(.secondary)
      }
    }
}

#Preview {
    LocationRow()
}
