//
//  AppView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct AppView: View {
    var body: some View {
      TabView {
        HomeView()
          .tabItem {
            Image(systemName: "house.fill")
            Text("Home")
          }
        
        ScanView()
          .tabItem {
            Image(systemName: "camera.fill")
            Text("New Scan")
          }
        
        ChatView()
          .tabItem {
            Image(systemName: "message.fill")
            Text("Chat")
          }
      }
    }
}

#Preview {
    AppView()
}
