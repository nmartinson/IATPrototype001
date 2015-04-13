//
//  Util.swift
//  lumichat
//
//  Created by Nick Martinson on 1/12/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Util: NSObject {

    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
    let fileManager = NSFileManager()
    let voice = AVSpeechSynthesizer()
    
    
    func speak(text: String)
    {
        var utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate
        voice.speakUtterance(utterance)
    }
    
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func createEditButton(target: UIViewController) -> UIButton
    {
        // Create navbar buttons
        let editButton = UIButton.buttonWithType(.System) as! UIButton
        editButton.frame = CGRectMake(0, 0, 100, 30)
        editButton.setTitle("Edit", forState: .Normal)
        editButton.addTarget(target, action: "editButtonPressed", forControlEvents: .TouchUpInside)
        editButton.contentHorizontalAlignment = .Right
        
        return editButton
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func createDoneEditingButton(target: UIViewController) -> UIButton
    {
        // Create navbar buttons
        let backButton = UIButton.buttonWithType(.System) as! UIButton
        backButton.frame = CGRectMake(0, 0, 100, 30)
        backButton.setTitle("Done Editing", forState: .Normal)
        backButton.addTarget(target, action: "doneEditing", forControlEvents: .TouchUpInside)
        backButton.contentHorizontalAlignment = .Left
        
        return backButton
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func createNavBarBackButton(target: UIViewController, string: String) -> UIButton
    {
        // Create navbar buttons
        let backButton = UIButton.buttonWithType(.System) as! UIButton
        backButton.frame = CGRectMake(0, 0, 100, 30)
        backButton.setTitle(" < \(string)", forState: .Normal)
        backButton.addTarget(target, action: "handleBack", forControlEvents: .TouchUpInside)
        backButton.layer.borderWidth = 3
        backButton.layer.borderColor = UIColor.blackColor().CGColor
        backButton.contentHorizontalAlignment = .Left

        return backButton
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    class func getPath(fileName: String) -> String
    {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
    }
    
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    class func copyFile(fileName: String)
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
        let unzippedPath = documentsPath.stringByAppendingPathComponent("unzippedData")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(unzippedPath, error: nil) as! [String]
        println(directoryContents)
        
        for(var i = 0; i < directoryContents.count; i++)
        {
            let sourcePath = documentsPath.stringByAppendingPathComponent("unzippedData/\(directoryContents[i])")
            let destinationPath = documentsPath.stringByAppendingPathComponent("images/user/\(directoryContents[i])")
            if fileManager.moveItemAtPath(sourcePath, toPath: destinationPath, error: &error) != true
            {
                println("Move image error: \(error)")
            }
        }
        
    }

    
    /* *******************************************************************************************************
    *	Saves image to a new 'image' directory in the Documents directory.
    ******************************************************************************************************* */
    func saveImage(image: UIImage?, title: String) -> String
    {
        if (image != nil)
        {
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            var path = documentDirectory.stringByAppendingPathComponent("images/stock") // append images to the directory string
            
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
            
            path = path.stringByAppendingString("/\(title).jpg") // append the image name with .jpg extension
            let data = UIImageJPEGRepresentation(image, 1) //create data from jpeg
            NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil) // write data to file
            let imagePath = "images/stock/\(title).jpg" // return only the path that is appended to the 'documents' path
            return imagePath
        }
        return ""
    }
    
    /* ************************************************************************************************
    *	Create a new directory to store the images in
    ************************************************************************************************ */
    func createDirectory(directory: String) -> String
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var path = documentsPath.stringByAppendingPathComponent(directory) // append images to the directory string
        
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
    
    /* ************************************************************************************************
    // returns the file paths inside the directory to zip
    ************************************************************************************************ */
    func getDirectory(path: String) -> [String]
    {
        var pathForZip = documentsPath.stringByAppendingPathComponent(path)
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pathForZip, error: nil) as! [String]
        
        for(var i = 0; i < directoryContents.count; i++)
        {
            directoryContents[i] = pathForZip.stringByAppendingString("/\(directoryContents[i])")
        }
        
        return directoryContents
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func deleteFileAtURL(url: NSURL)
    {
        var error:NSError?
        fileManager.removeItemAtURL(url, error: &error)
        if error != nil
        {
            println("Delete file error: \(error)")
        }
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func deleteFile(path: String)
    {
        let filePath = documentsPath.stringByAppendingPathComponent(path)
        var error:NSError?
        fileManager.removeItemAtPath(filePath, error: &error)
        if error != nil
        {
            println("Delete file error: \(error)")
        }
    }
    
}