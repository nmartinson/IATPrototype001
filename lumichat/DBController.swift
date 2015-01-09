//
//  DBController.swift
//  lumichat
//
//  Created by Nick Martinson on 12/14/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation

class DBController
{
    
    public class var sharedInstance: DBController{
        struct SharedInstance {
            static let instance = DBController()
        }
        return SharedInstance.instance
    }
    
    /* *****************************************************************************************************
    *	Creates and returns the file path to the database
    ****************************************************************************************************** */
    func getDB(filePath: String) -> FMDatabase
    {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let docsPath: String = paths
        let path = docsPath.stringByAppendingPathComponent(filePath)
        return FMDatabase(path: path)
    }

}