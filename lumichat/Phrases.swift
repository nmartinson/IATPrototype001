//
//  Phrases.swift
//  lumichat
//
//  Created by Nick Martinson on 1/28/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class Phrases: NSManagedObject
{
    @NSManaged var text:String
    @NSManaged var presses:NSNumber
}