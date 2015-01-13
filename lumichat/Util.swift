//
//  Util.swift
//  lumichat
//
//  Created by Nick Martinson on 1/12/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class Util: NSObject {

    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
    let fileManager = NSFileManager()
    
    
    class func getPath(fileName: String) -> String
    {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
    }
    
    class func copyFile(fileName: NSString)
    {
        var dbPath: String = getPath(fileName)
        var fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath)
        {
            var fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName)
            fileManager.copyItemAtPath(fromPath!, toPath: dbPath, error: nil)
        }
    }
    
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func moveImages()
    {
        var error:NSError?
        let unzippedPath = documentsPath.stringByAppendingPathComponent("")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(unzippedPath, error: nil) as [String]
        println(directoryContents)
        
        for(var i = 0; i < directoryContents.count; i++)
        {
            let sourcePath = documentsPath.stringByAppendingPathComponent("unzippedData/\(directoryContents[i])")
            let destinationPath = documentsPath.stringByAppendingPathComponent("images/user/\(directoryContents[i])")
            if fileManager.moveItemAtPath(sourcePath, toPath: destinationPath, error: &error) != true
            {
                println("Replace database error: \(error)")
            }
        }
        
    }

    
}