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

  @State private var isKeyboardVisible = false
  @State private var needToSave = false

  var body: some View {
        ZStack {
            VStack {
                NavigationStack(path: $path) {
                    switch selectedTab {
                    case .house:
                        HomeView(navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote)
                            .onAppear {
                                if let course = navigateToCourse, let note = navigateToNote {
                                    path.append(course)
                                    path.append(note)
                                    navigateToCourse = nil
                                    navigateToNote = nil
                                }
                            }
                    case .scan:
                        ScanView(selectedTabIndex: .constant(0), navigateToCourse: $navigateToCourse, navigateToNote: $navigateToNote,
                        needToSave: $needToSave)
                    case .chat:
                        ChatView()
                    }
                }
                Spacer()
            }
          // This conditional padding is needed for the keyboard in ChatView to cover the CustomTabBar without too much padding
            .padding(.bottom, isKeyboardVisible ? 0 : 50)
            Spacer()
            VStack {
             Spacer()
             CustomTabBar(selectedTab: $selectedTab, tabs: Tab.allCases, onTabSelected: { tab in
               // Shows alert only if swtiching away from chat and scan tab
               if (selectedTab == .chat || selectedTab == .scan) && needToSave {
                 pendingTab = tab
                 showAlert = true
               } else {
                // if selectedTab == .house {
                //         path.removeLast(path.count) // Reset the navigation stack
                //     }
                 selectedTab = tab
                 NotificationCenter.default.post(name: tab.notificationName, object: nil)
               }
             })
           }
           .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
            }
            NotificationCenter.default.addObserver(forName: .resetHomeView, object: nil, queue: .main) { _ in
                selectedTab = .house
                path.removeLast(path.count) // Reset the navigation stack
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .resetHomeView, object: nil)
        }
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
                        needToSave = false
                   }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    AppView()
}
