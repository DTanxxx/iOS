//
//  TestingUITests.swift
//  TestingUITests
//
//  Created by David Tan on 14/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import XCTest

class TestingUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testInitialStateIsCorrect() {
        XCUIApplication().activate()
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }
    
    // for this test method, we used test recording (more detail in the book)
    func testUserFilteringByString() {
        XCUIApplication().activate()
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("test")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }
    
    func testUserFilteringByInt() {
        XCUIApplication().activate()
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("1000")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 55, "There should be 55 words with 1000 or more frequencies")
    }
    
    func testCancelButtonIsFunctional() {
        XCUIApplication().activate()
        let app = XCUIApplication()
        let numOfRowsBeforeSearch = app.tables.cells.count
        
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        filterAlert.buttons["Cancel"].tap()
        
        XCTAssertEqual(app.tables.cells.count, numOfRowsBeforeSearch, "There should not be any changes in table view rows when Cancel button is pressed")
    }
}


