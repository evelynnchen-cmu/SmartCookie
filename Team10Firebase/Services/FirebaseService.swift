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
    
    func fetchCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
        db.collection("Course").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching courses: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found.")
                completion(.success([]))
                return
            }
            
            let courses: [Course] = documents.compactMap { document in
                do {
                    let course = try document.data(as: Course.self)
                    print("Fetched course: \(course)")
                    return course
                } catch {
                    print("Error decoding course: \(error.localizedDescription)")
                    return nil
                }
            }
            
            print("Total courses fetched: \(courses.count)")
            completion(.success(courses))
        }
    }
}
