//
//  ChatView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct ChatView: View {
  var courseScope: String
    var body: some View {
//      Note: VStack needed or else a duplicate tab in AppView is created
      VStack {
        Text("Chat")
        Text("\(courseScope)")
      }
    }
}

//#Preview {
//    ChatView()
//}
