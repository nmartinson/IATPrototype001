//
//  BodyParts.swift
//  lumichat
//
//  Created by Nick Martinson on 1/12/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class Tables: NSManagedObject {

    @NSManaged var number: NSNumber
    @NSManaged var title: String
    @NSManaged var longDescription: String
    @NSManaged var image: String
    @NSManaged var presses: NSNumber
    @NSManaged var table: String

}
