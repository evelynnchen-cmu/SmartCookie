//
//  CustomTabView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/28/24.
//

import SwiftUI
import Foundation

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
                }) {
                    VStack {
                        Image(systemName: tab.rawValue)
                        Text(tab.text)
                    }
                    .padding()
                    .foregroundColor(selectedTab == tab ? Color(UIColor.systemGray4) : .white)
                }
                if tab != tabs.last {
                  Spacer()
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
      // This padding controls how close the tab buttons are to each other
        .padding(.horizontal, 36)
        .padding(.top, 8)
        // This frame controls the height of the tab bar
        .frame(maxHeight: 60)
        .background(Color.blue.opacity(0.5))
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

extension NSNotification.Name {
    static let resetHomeView = NSNotification.Name("resetHomeView")
    static let resetScanView = NSNotification.Name("resetScanView")
    static let resetChatView = NSNotification.Name("resetChatView")
}
