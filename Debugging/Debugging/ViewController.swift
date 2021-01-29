//
//  ViewController.swift
//  Debugging
//
//  Created by David Tan on 17/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: - Debugging with print()
        //printDebug()
                
        
        // MARK: - Debugging with assert()
        //assertDebug()
        
        
        // MARK: - Debugging with breakpoints
        for i in 1 ... 100 {
            print("Got number \(i)")
        }
        // The threads on the left of debugging window show back trace of your program. If you find a bug somewhere in method d(), this back trace will show you that d() was called by c(), which was called by b(), which in turn was called by a() – it effectively shows you the events leading up to your problem, which is invaluable when trying to spot bugs.
        // You can make breakpoints conditional, meaning that they will pause execution of your program only if the condition is matched.
        // Breakpoints can also be automatically triggered when an exception is thrown. Exceptions are errors that aren't handled, and will cause your code to crash. With breakpoints, you can say "pause execution as soon as an exception is thrown," so that you can examine your program state and see what the problem is.
        
        
        // MARK: - View debugging
        // Capture View Hierarchy
    }
    
    func printDebug() {
        // print() is a variadic function
        print(1, 2, 3, 4, 5)
        print(1, 2, 3, 4, 5, separator: "-")
        print("Some message", terminator: "")
        // By default "\n" is passed into terminator parameter, so there is a line break after each call
        print("Some message")
    }
    
    func assertDebug() {
        // assertions are checks that will force your app to crash if a specific condition isn't true, therefore use them abundantly
        assert(1 == 1, "Maths failure!")
        assert(1 == 2, "Maths failure!")
        // assert() takes in something to check, and a message to print out of the check fails
        // assert() is never executed in the product app in app store, so use freely
        assert(myReallySlowMethod() == true, "The slow method returned false, which is wrong!")
        // This myReallySlowMethod() call will execute only while you’re running test builds – that code will be removed entirely when you build for the App Store.
    }
    
    func myReallySlowMethod() -> Bool {
        return true
    }
    
    
}

