//
//  SettingsView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/12/24.
//


import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
   @StateObject private var firebase = Firebase()
   @State private var notesOnlyChatScope: Bool = false
   @State private var notesOnlyQuizScope: Bool = false
   @State private var notificationsEnabled: Bool = false
   @State private var notificationFrequency: String = "3x per week"
   @State private var errorMessage: String?
   
   private let frequencies = [
       "Daily",
       "3x per week",
       "2x per week",
       "Weekly"
   ]
   
   var body: some View {
       NavigationView {
           List {
             Section {
                 VStack(alignment: .leading, spacing: 0) {
                     VStack(alignment: .leading) {
                         Toggle("Search notes only (Chat)", isOn: $notesOnlyChatScope)
                             .onChange(of: notesOnlyChatScope) { _, newValue in
                                 firebase.toggleNotesOnlyChatScope(isEnabled: newValue) { error in
                                     if let error = error {
                                         errorMessage = error.localizedDescription
                                     }
                                 }
                             }
                     }
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.white)
                     .cornerRadius(10)
                     
                     Text("When chatting, the AI assistant won't give you any information from online sources")
                         .font(.footnote)
                         .foregroundColor(.gray)
                         .padding(.horizontal)
                         .padding(.top, 4)
                 }
                 .listRowBackground(Color(.systemGroupedBackground))
                 .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                 
                 VStack(alignment: .leading, spacing: 0) {
                     VStack(alignment: .leading) {
                         Toggle("Use notes only (Quiz)", isOn: $notesOnlyQuizScope)
                             .onChange(of: notesOnlyQuizScope) { _, newValue in
                                 firebase.toggleNotesOnlyQuizScope(isEnabled: newValue) { error in
                                     if let error = error {
                                         errorMessage = error.localizedDescription
                                     }
                                 }
                             }
                     }
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.white)
                     .cornerRadius(10)
                     
                     Text("Quizzes will only generate questions based on your selected note")
                         .font(.footnote)
                         .foregroundColor(.gray)
                         .padding(.horizontal)
                         .padding(.top, 4)
                 }
                 .listRowBackground(Color(.systemGroupedBackground))
                 .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0))
             } header: {
                 Text("AI Scope")
             }
               
               Section(header: Text("Notifications")) {
                   Toggle(isOn: $notificationsEnabled) {
                       Text("Enable Notifications")
                   }
                   .onChange(of: notificationsEnabled) { newValue in
                       firebase.toggleNotificationsEnabled(isEnabled: newValue) { error in
                           if let error = error {
                               print("Failed to toggle notification preferences: \(error.localizedDescription)")
                           }
                       }
                   }
                   
                   if notificationsEnabled {
                       Picker("Reminder Frequency", selection: $notificationFrequency) {
                           ForEach(frequencies, id: \.self) { frequency in
                               Text(frequency.capitalized)
                           }
                       }
                       .onChange(of: notificationFrequency) { newValue in
                           firebase.updateNotificationFrequency(newValue) { error in
                               if let error = error {
                                   print("Failed to update notification frequency: \(error.localizedDescription)")
                               }
                           }
                       }
                   }
               }
           }
           .navigationTitle("Settings")
           .alert("Error", isPresented: .constant(errorMessage != nil)) {
               Button("OK") {
                   errorMessage = nil
               }
           } message: {
               if let errorMessage = errorMessage {
                   Text(errorMessage)
               }
           }
           .onAppear {
               firebase.getFirstUser { user in
                   if let user = user {
                       notesOnlyChatScope = user.settings.notesOnlyChatScope
                       notesOnlyQuizScope = user.settings.notesOnlyQuizScope
                       notificationsEnabled = user.settings.notificationsEnabled
                       notificationFrequency = user.settings.notificationFrequency
                   }
               }
           }
       }
   }
}
