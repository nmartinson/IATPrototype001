//
//  DBController.swift
//  lumichat
//
//  Created by Nick Martinson on 12/14/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

let sharedInstance = DBController()

class DBController: NSObject
{
    public class var sharedInstance: DBController{
        struct SharedInstance {
            static let instance = DBController()
        }
        return SharedInstance.instance
    }
//    var currentDB: FMDatabase? = nil
//    var importedDB: FMDatabase? = nil
//    
//    class var currentDBInstance: DBController
//    {
//        sharedInstance.currentDB = FMDatabase(path: Util.getPath("UserDatabase.sqlite"))
//        return sharedInstance
//    }
//    
//    class var importedDBInstance: DBController
//    {
//        sharedInstance.importedDB = FMDatabase(path: Util.getPath("unzippedData/UserDatabase.sqlite"))
//        return sharedInstance
//    }
    
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