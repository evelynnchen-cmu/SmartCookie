//
//  FirebaseService.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/29/24.
//
import Foundation
import FirebaseFirestore

class FirebaseService {
    private let db = Firestore.firestore()
    
    // func fetchCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
    //     db.collection("Course").getDocuments { (querySnapshot, error) in
    //         if let error = error {
    //             print("Error fetching courses: \(error.localizedDescription)")
    //             completion(.failure(error))
    //             return
    //         }
            
    //         guard let documents = querySnapshot?.documents else {
    //             print("No documents found.")
    //             completion(.success([]))
    //             return
    //         }
            
    //         let courses: [Course] = documents.compactMap { document in
    //             do {
    //                 let course = try document.data(as: Course.self)
    //                 print("Fetched course: \(course)")
    //                 return course
    //             } catch {
    //                 print("Error decoding course: \(error.localizedDescription)")
    //                 return nil
    //             }
    //         }
            
    //         print("Total courses fetched: \(courses.count)")
    //         completion(.success(courses))
    //     }
    // }
    import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var courses: [Course] = []

    func fetchCourses() {
        db.collection("courses").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching courses: \(error.localizedDescription)")
                return
            }
            
            let result: [Course] = querySnapshot?.documents.compactMap { document in
                let course = try? document.data(as: Course.self)
                if var data = course {
                    data.id = document.documentID
                    return data
                }
                return nil
            } ?? []
            
            self.courses = result
            
            print("Total courses fetched: \(self.courses.count)")
            }
        }
    }

    func getCourses() -> [Course] {
        return courses
    }
}
