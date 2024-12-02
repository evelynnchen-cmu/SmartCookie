// // //
// // //  CustomTabView.swift
// // //  Team10Firebase
// // //
// // //  Created by Emma Tong on 11/28/24.
// // //

  import SwiftUI
  import Foundation

// extension NSNotification.Name {
//     static let resetHomeView = NSNotification.Name("resetHomeView")
//     static let resetScanView = NSNotification.Name("resetScanView")
//     static let resetChatView = NSNotification.Name("resetChatView")
// }

// enum Tab: String, CaseIterable {
//     case house
//     case scan = "camera.fill"
//     case chat = "message.fill"
    
//     var text: String {
//         switch self {
//         case .house:
//             return "Home"
//         case .scan:
//             return "Scan"
//         case .chat:
//             return "Chat"
//         }
//     }
// }

// struct CustomTabView<Content: View>: View {
//     @Binding var selectedTab: Tab
//     let content: Content

//     init(selectedTab: Binding<Tab>, @ViewBuilder content: () -> Content) {
//         self._selectedTab = selectedTab
//         self.content = content()
//     }

//     var body: some View {
//         TabView(selection: $selectedTab) {
//             content
//         }
//         .onChange(of: selectedTab) { newValue in
//             if newValue == .house {
//                 NotificationCenter.default.post(name: .resetHomeView, object: nil)
//             }
//         }
//     }
// }

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @State private var previousTab: Tab?
    let tabs: [Tab]
    var onTabSelected: (Tab) -> Void

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    onTabSelected(tab)
                    // TODO: Preserve state across tabs?
                    // Last implementation
                    // if selectedTab == tab {
                    //     NotificationCenter.default.post(name: tab.notificationName, object: nil)
                    // }
                    // selectedTab = tab

                    // if selectedTab == tab && previousTab != nil && previousTab == selectedTab {
                    //     NotificationCenter.default.post(name: previousTab!.notificationName, object: nil)
                    // }
                    // previousTab = selectedTab
                    // selectedTab = tab
                }) {
                    VStack {
                        Image(systemName: tab.rawValue)
                        Text(tab.text)
                    }
//                    .ignoresSafeArea(edges: .all)
                     .padding()
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                }
                if tab != tabs.last {
                  Spacer()
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .ignoresSafeArea(edges: .all)
      // This padding controls how close the tab buttons are to each other
        .padding(.horizontal, 36)
        // This frame controls the height of the tab bar
        .frame(maxHeight: 60)
        .background(Color.white)
    }
}

extension Tab {
    var notificationName: NSNotification.Name {
        switch self {
        case .house:
            return .resetHomeView
        case .scan:
            return .resetScanView
        case .chat:
            return .resetChatView
        }
    }
}
