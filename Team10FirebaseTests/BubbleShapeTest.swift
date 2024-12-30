//
//  BubbleShapeTest.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/29/24.
//

import XCTest
import SwiftUI
@testable import Team10Firebase

class BubbleShapeTests: XCTestCase {
    

    func testUserBubblePath() {
        let bubbleShape = BubbleShape(isUser: true)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = bubbleShape.path(in: rect)
        XCTAssertFalse(path.isEmpty)
        let bounds = path.boundingRect
        XCTAssertTrue(bounds.width <= rect.width + 5, "Path width should be within expected bounds")
        XCTAssertTrue(bounds.height <= rect.height + 2, "Path height should be within expected bounds")
        XCTAssertGreaterThanOrEqual(bounds.minX, -2, "Minimum X should not extend too far left")
        XCTAssertLessThanOrEqual(bounds.maxX, rect.width + 2, "Maximum X should not extend too far right")
    }
    

    func testNonUserBubblePath() {
        let bubbleShape = BubbleShape(isUser: false)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let path = bubbleShape.path(in: rect)
        XCTAssertFalse(path.isEmpty)
        let bounds = path.boundingRect
        XCTAssertTrue(bounds.width <= rect.width + 5, "Path width should be within expected bounds")
        XCTAssertTrue(bounds.height <= rect.height + 2, "Path height should be within expected bounds")
        XCTAssertGreaterThanOrEqual(bounds.minX, -2, "Minimum X should not extend too far left")
        XCTAssertLessThanOrEqual(bounds.maxX, rect.width + 2, "Maximum X should not extend too far right")
    }
    

    func testVariousRectSizes() {
        let testSizes = [
            CGRect(x: 0, y: 0, width: 50, height: 25),
            CGRect(x: 0, y: 0, width: 200, height: 100),
            CGRect(x: 0, y: 0, width: 300, height: 150)
        ]
        
        for rect in testSizes {
            let userBubble = BubbleShape(isUser: true)
            let userPath = userBubble.path(in: rect)
            XCTAssertFalse(userPath.isEmpty, "User path should not be empty")
            
            let nonUserBubble = BubbleShape(isUser: false)
            let nonUserPath = nonUserBubble.path(in: rect)
            XCTAssertFalse(nonUserPath.isEmpty, "Non-user path should not be empty")
        }
    }

    func testMinimumSizes() {
        let bubbleShape = BubbleShape(isUser: true)
        let rect = CGRect(x: 0, y: 0, width: 40, height: 30) 
        
        let path = bubbleShape.path(in: rect)
        XCTAssertFalse(path.isEmpty, "Path should not be empty even with minimum size")
    }
    

    func testLargeSizes() {
        let bubbleShape = BubbleShape(isUser: true)
        let rect = CGRect(x: 0, y: 0, width: 1000, height: 500)
        
        let path = bubbleShape.path(in: rect)
        XCTAssertFalse(path.isEmpty, "Path should not be empty with large size")
        
        let bounds = path.boundingRect
        XCTAssertTrue(bounds.width <= rect.width + 5, "Large path width should be within bounds")
        XCTAssertTrue(bounds.height <= rect.height + 2, "Large path height should be within bounds")
    }

    func testPathConsistency() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let bubbleShape = BubbleShape(isUser: true)
        
        let path1 = bubbleShape.path(in: rect)
        let path2 = bubbleShape.path(in: rect)
        
        XCTAssertEqual(path1.boundingRect.width, path2.boundingRect.width, accuracy: 0.01)
        XCTAssertEqual(path1.boundingRect.height, path2.boundingRect.height, accuracy: 0.01)
    }
    
    func testPerformance() {
        let bubbleShape = BubbleShape(isUser: true)
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        measure {
            for _ in 0..<100 {
                _ = bubbleShape.path(in: rect)
            }
        }
    }
}
