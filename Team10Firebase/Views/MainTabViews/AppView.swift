//
//  AppView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct AppView: View {
  @State private var selectedTabIndex = 0 // For home
  @State private var navigateToCourse: Course?
  @State private var navigateToNote: Note?

    var body: some View {
      TabView(selection: $selectedTabIndex) {
        HomeView(navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
          .tabItem {
            Image(systemName: "house.fill")
            Text("Home")
          }
          .tag(0)
        
        ScanView(selectedTabIndex: $selectedTabIndex, navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
          .tabItem {
            Image(systemName: "camera.fill")
            Text("New Scan")
          }
          .tag(1)
        
        ChatView()
          .tabItem {
            Image(systemName: "message.fill")
            Text("Chat")
          }
          .tag(2)
      }
    }
}

#Preview {
    AppView()
}
