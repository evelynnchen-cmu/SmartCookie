//
//  Firebase.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/29/24.
//

import Foundation
import FirebaseFirestore

class Firebase: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var courses: [Course] = []
    
    private let courseCollection = "Course"
    
    func fetchCourses() {
        db.collection(courseCollection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching courses: \(error.localizedDescription)")
                return
            }
            
            self.courses = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Course.self)
            } ?? []
            
            print("Total courses fetched: \(self.courses.count)")
            for course in self.courses {
                print("Fetched course: \(course)")
            }
        }
    }
}