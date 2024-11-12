//
//  SettingsView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/12/24.
//


import SwiftUI

struct SettingsView: View {
    @StateObject private var firebase = Firebase()
    @State private var isNotesOnlyChatScope: Bool = false
    @State private var isNotesOnlyQuizScope: Bool = false
    @State private var isNotificationsEnabled: Bool = false
    
    var body: some View {
      Form {
          Toggle(isOn: $isNotesOnlyChatScope) {
              Text("Notes Only Chat Scope")
          }
          .onChange(of: isNotesOnlyChatScope) { oldValue, newValue in
              firebase.toggleNotesOnlyChatScope(isEnabled: newValue) { error in
                  if let error = error {
                      print("Failed to toggle chat scope: \(error.localizedDescription)")
                  }
              }
          }
        
        Toggle(isOn: $isNotesOnlyQuizScope) {
            Text("Notes Only Quiz Scope")
        }
        .onChange(of: isNotesOnlyQuizScope) { oldValue, newValue in
            firebase.toggleNotesOnlyQuizScope(isEnabled: newValue) { error in
                if let error = error {
                    print("Failed to toggle quiz scope: \(error.localizedDescription)")
                }
            }
        }
        
        Toggle(isOn: $isNotificationsEnabled) {
            Text("Notifications")
        }
        .onChange(of: isNotificationsEnabled) { oldValue, newValue in
            firebase.toggleNotificationsEnabled(isEnabled: newValue) { error in
                if let error = error {
                    print("Failed to toggle notification preferences: \(error.localizedDescription)")
                }
            }
        }
      }
        .navigationTitle("Settings")
        .onAppear {
            firebase.getFirstUser { user in
                if let user = user {
                    isNotesOnlyChatScope = user.settings.notesOnlyChatScope
                    isNotesOnlyQuizScope = user.settings.notesOnlyQuizScope
                    isNotificationsEnabled = user.settings.notificationsEnabled
                } else {
                    print("Failed to fetch user.")
                }
            }
        }
    }
}
