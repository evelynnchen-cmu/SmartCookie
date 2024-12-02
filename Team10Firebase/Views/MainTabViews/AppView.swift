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

  @State private var selectedTab = Tab.house
  @State private var path = NavigationPath()

  @State private var showAlert = false
  @State private var pendingTab: Tab?

  //   var body: some View {
  //     ZStack {
  //     // TabView(selection: $selectedTab) {
  //     CustomTabView(selectedTab: $selectedTab) {
  //       HomeView(navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
  //         .tabItem {
  //           Image(systemName: "house.fill")
  //           Text("Home")
  //         }
  //         .tag(Tab.house)
        
  //       ScanView(selectedTabIndex: $selectedTabIndex, navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
  //         .tabItem {
  //           Image(systemName: "camera.fill")
  //           Text("New Scan")
  //         }
  //         .tag(Tab.scan)
        
  //       ChatView()
  //         .tabItem {
  //           Image(systemName: "message.fill")
  //           Text("Chat")
  //         }
  //         .tag(Tab.chat)
  //     }
  //     .onAppear {
  //         UITabBar.appearance().backgroundColor = UIColor.white
  //     }
  //     .onChange(of: selectedTab) { newValue in
  //         if newValue == .house {
  //             NotificationCenter.default.post(name: .resetHomeView, object: nil)
  //         } else if newValue == .scan {
  //             NotificationCenter.default.post(name: .resetScanView, object: nil)
  //         } else if newValue == .chat {
  //             NotificationCenter.default.post(name: .resetChatView, object: nil)
  //         }
  //     }
  //   }
  // }
  var body: some View {
        VStack {
            ZStack {
                 switch selectedTab {
//              switch pendingTab {
              case .house:
                HomeView(navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
              case .scan:
                ScanView(selectedTabIndex: .constant(0), navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
              case .chat:
                ChatView()
//              case nil:
//                HomeView(navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
              }
            }
            Spacer()
            //  CustomTabBar(selectedTab: $selectedTab, tabs: Tab.allCases)
            CustomTabBar(selectedTab: $selectedTab, tabs: Tab.allCases, onTabSelected: { tab in
            // Will pop alert for all tabs
                // pendingTab = tab
                // showAlert = true

                // Shows alert only if swtiching away from chat and scan tab
                if selectedTab == .chat || selectedTab == .scan {
                    pendingTab = tab
                    showAlert = true
                } else {
                    selectedTab = tab
                    NotificationCenter.default.post(name: tab.notificationName, object: nil)
                }
            })
//            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
        }
        // .onChange(of: selectedTab) { newTab in
        //     if newTab != selectedTab {
        //         pendingTab = newTab
        //         showAlert = true
        //         selectedTab = selectedTab // Revert the change
        //     }
        // }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to switch tabs?"),
                message: Text("You will lose any unsaved data."),
                primaryButton: .destructive(Text("Switch")) {
                   if let tab = pendingTab {
                        if tab == .house {
                            NotificationCenter.default.post(name: .resetHomeView, object: nil)
                        } else if tab == .scan {
                            NotificationCenter.default.post(name: .resetScanView, object: nil)
                        } else if tab == .chat {
                            NotificationCenter.default.post(name: .resetChatView, object: nil)
                        }
                        selectedTab = tab
                   }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

enum Tab: String, CaseIterable {
    case house = "house.fill"
    case scan = "camera.fill"
    case chat = "message.fill"
    
    var text: String {
        switch self {
        case .house:
            return "Home"
        case .scan:
            return "Scan"
        case .chat:
            return "Chat"
        }
    }
}

extension NSNotification.Name {
    static let resetHomeView = NSNotification.Name("resetHomeView")
    static let resetScanView = NSNotification.Name("resetScanView")
    static let resetChatView = NSNotification.Name("resetChatView")
}

#Preview {
    AppView()
}
