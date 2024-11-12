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
      }
        .navigationTitle("Settings")
        .onAppear {
            firebase.getFirstUser { user in
                if let user = user {
                    isNotesOnlyChatScope = user.settings.notesOnlyChatScope
                } else {
                    print("Failed to fetch user.")
                }
            }
        }
    }
}
