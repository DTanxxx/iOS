//
//  Commit+CoreDataClass.swift
//  Core_Data
//
//  Created by David Tan on 11/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
