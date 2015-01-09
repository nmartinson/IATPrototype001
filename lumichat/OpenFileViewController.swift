//
//  OpenFileViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 1/8/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class OpenFileViewController: UIViewController
{
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var overwriteButton: UIButton!
    @IBOutlet weak var mergeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var url:NSURL?
    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String

    override func viewDidLoad()
    {
        let inboxPath = documentsPath.stringByAppendingPathComponent("Inbox")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(inboxPath, error: nil) as [String]
        println("directory contents \(directoryContents)")
    }
    
    
    @IBAction func overwriteButtonPressed(sender: AnyObject)
    {
        let zip = Zipping()
        
        createDirectory("unzippedData")
        let sourcePath = documentsPath.stringByAppendingPathComponent("Inbox/file.zip")
        let destinationPath = documentsPath.stringByAppendingPathComponent("unzippedData")
        zip.unZipDirectory(sourcePath, destination: destinationPath)
        
        let filemgr = NSFileManager()
        var error:NSError?
        filemgr.contentsOfDirectoryAtPath(destinationPath, error: &error)
        if error != nil
        {
            println("Unzipping error: \(error)")
        }
        
        deleteFile("UserDatabase.sqlite") // delete old database
        replaceDatabase() // moves new database into place
        createDirectory("images/user")
        moveImages()
    }
    
    @IBAction func mergeButtonPressed(sender: AnyObject)
    {
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.deleteFileAtURL(self.url!)
        })

    }
    
    func moveImages()
    {
        var error:NSError?
        let fileManager = NSFileManager()
        let unzippedPath = documentsPath.stringByAppendingPathComponent("unzippedData")
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
    
    func replaceDatabase()
    {
        var error:NSError?
        let fileManager = NSFileManager()
        let tempPath = documentsPath.stringByAppendingPathComponent("unzippedData/UserDatabase.sqlite")
        let destinationPath = documentsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
        if fileManager.moveItemAtPath(tempPath, toPath: destinationPath, error: &error) != true
        {
            println("Replace database error: \(error)")
        }
    }
    
    func deleteFileAtURL(url: NSURL)
    {
        let fileManager = NSFileManager()
        var error:NSError?
        fileManager.removeItemAtURL(url, error: &error)
        if error != nil
        {
            println("Delete file error: \(error)")
        }
    }
    
    func deleteFile(path: String)
    {
        let filePath = documentsPath.stringByAppendingPathComponent(path)
        let fileManager = NSFileManager()
        var error:NSError?
        fileManager.removeItemAtPath(filePath, error: &error)
        if error != nil
        {
            println("Delete file error: \(error)")
        }
    }
    
    /* ************************************************************************************************
    // returns the file paths inside the directory to zip
    ************************************************************************************************ */
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
    
}