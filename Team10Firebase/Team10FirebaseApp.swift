//
//  Team10FirebaseApp.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 10/21/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct Team10FirebaseApp: App {

//    init() {
//            FirebaseApp.configure()
//    }
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
//            ContentView() // Your app's content
          AppView()
        }
    }
}
