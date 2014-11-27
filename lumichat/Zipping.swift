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
    func zipDirectory(sourceDirectory: String, destination: String)
    {
        var directoryContents = getDirectory(sourceDirectory)   // gets the array of the file paths inside a directory
        SSZipArchive.createZipFileAtPath(destination, withFilesAtPaths: directoryContents)  // zips up files
    }
    
    // unzips file to directory
    func unZipDirectory(sourceFile: String, destination: String)
    {
        SSZipArchive.unzipFileAtPath(sourceFile, toDestination: destination) // unzips zip file to specified file path
    }
 
    // returns the file paths inside the directory to zip
    func getDirectory(path: String) -> [String]
    {
        var pathForZip = documentsPath.stringByAppendingPathComponent("images")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil) as [String]
        
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
    
    
}





//var pathForZip = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
//let zipPath:NSString = pathForZip.stringByAppendingString("/files1.zip")    // specifies file to zip to
//let unZipPath:NSString = pathForZip.stringByAppendingPathComponent("zipped2")   // directory to unzip to
//var directoryForZip = pathForZip.stringByAppendingPathComponent("images")   // directory to zip up
//var directoryContents = getDirectory(directoryForZip)   // gets the array of the file paths inside a directory
//
//SSZipArchive.createZipFileAtPath(zipPath, withFilesAtPaths: directoryContents)  // zips up files
//SSZipArchive.unzipFileAtPath(zipPath, toDestination: unZipPath) // unzips zip file to specified file path
        