//
//  TestingTests.swift
//  TestingTests
//
//  Created by David Tan on 14/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import XCTest
@testable import Testing

class TestingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // every test method's name should start with "test..."
    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.allWords.count, 18440, "allWords was not 18440")  // this method checks that its first parameter (playData.allWords.count) equals its second parameter (0). If it doesn't, the test will fail and print the message given in parameter three ("allWords must be 0").
    }
    
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "deceased"), 5, "Deceased does not appear 5 times")
        XCTAssertEqual(playData.wordCounts.count(for: "read"), 81, "Read does not appear 81 times")
        XCTAssertEqual(playData.wordCounts.count(for: "ere"), 127, "Ere does not appear 127 times")
    }
    
    func testWordsLoadQuickly() {
        // this test measures the amount of time it takes for the PlayData() object to be created, essentially measuring the performance of our new word frequency code
        measure {
            _ = PlayData()
        }
    }
    
    func testApplyUserFilterQuickly() {
        let playData = PlayData()
        
        measure {
            playData.applyUserFilter("test")
            playData.applyUserFilter("100")
        }
    }
    
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495, "Number of words with word count greater or equal to 100 is not 495")
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55, "Number of words with word count greater or equal to 1000 is not 55")
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1, "Number of words with word count greater or equal to 10000 is not 1")
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56, "Number of words containing 'test' is not 56")
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7, "Number of words containing 'swift' is not 7")
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0, "Number of words containing 'objective-c' is not 0")
        
    }
    
    

}
