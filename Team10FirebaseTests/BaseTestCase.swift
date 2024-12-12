//
//  BaseTestCase.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/11/24.
//


import XCTest
@testable import Team10Firebase

class BaseTestCase: XCTestCase {
    var mockFirebase: MockFirebase!
    var mockOpenAI: MockOpenAI!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        mockOpenAI = MockOpenAI()
    }
    
    override func tearDown() {
        mockFirebase = nil
        mockOpenAI = nil
        super.tearDown()
    }
}
