//
//  Zipping.swift
//  lumichat
//
//  Created by Nick Martinson on 11/27/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation

class Zipping
{
    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String

    // zips directory to file
    // zipDirectory("images", destination: "daterbase.zip")
    func zipDirectory(sourceDirectory: String, destination: String)
    {
        var desFolder = getFilePath(destination)
        var directoryContents = getDirectory(sourceDirectory)   // gets the array of the file paths inside a directory
        var complete = SSZipArchive.createZipFileAtPath(desFolder, withFilesAtPaths: directoryContents)  // zips up files
    }
    
    // unzips file to directory
    func unZipDirectory(sourceFile: String, destination: String)
    {
        SSZipArchive.unzipFileAtPath(sourceFile, toDestination: destination) // unzips zip file to specified file path
    }
 
    // returns the file paths inside the directory to zip
    func getDirectory(path: String) -> [String]
    {
        var pathForZip = documentsPath.stringByAppendingPathComponent(path)
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pathForZip, error: nil) as [String]
        
        for(var i = 0; i < directoryContents.count; i++)
        {
            directoryContents[i] = pathForZip.stringByAppendingString("/\(directoryContents[i])")
        }
        
        return directoryContents
    }
    
    
    /* ************************************************************************************************
    *	Create a new directory to store the images in
    ************************************************************************************************ */
    func createDirectory(directory: String) -> String
    {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = documentDirectory.stringByAppendingPathComponent(directory) // append images to the directory string
        
        if(!NSFileManager.defaultManager().fileExistsAtPath(path))
        {
            var error:NSError?
            if(!NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)) // create new images directory
            {
                if (error != nil)
                {
                    println("Create directory error \(error)")
                }
            }
        }
        return path
    }
    
    // returns the directory path of the file
    // example: getFilePath("daterbase.zip")
    func getFilePath(file: String) -> String
    {
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let filePath:NSString = path.stringByAppendingString("/\(file)")
        return filePath
    }
}