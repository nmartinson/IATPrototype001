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
    let fileManager = NSFileManager()

    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    override func viewDidLoad()
    {
        let inboxPath = documentsPath.stringByAppendingPathComponent("Inbox")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(inboxPath, error: nil) as [String]
        println("directory contents \(directoryContents)")
    }
    
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    @IBAction func overwriteButtonPressed(sender: AnyObject)
    {
        let zip = Zipping()
        
        createDirectory("unzippedData")
        let sourcePath = documentsPath.stringByAppendingPathComponent("Inbox/file.zip")
        let destinationPath = documentsPath.stringByAppendingPathComponent("unzippedData")
        zip.unZipDirectory(sourcePath, destination: destinationPath)
        
        var error:NSError?
        fileManager.contentsOfDirectoryAtPath(destinationPath, error: &error)
        if error != nil
        {
            println("Unzipping error: \(error)")
        }
        
        deleteFile("UserDatabase.sqlite") // delete old database
        replaceDatabase() // moves new database into place
        createDirectory("images/user")
        moveImages()
        notifyCompletion("Library overwritten!") { (block) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }

    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    @IBAction func mergeButtonPressed(sender: AnyObject)
    {
        
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        self.notifyCompletion("Import canceled!") { (block) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func moveImages()
    {
        var error:NSError?
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
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func replaceDatabase()
    {
        var error:NSError?
        let tempPath = documentsPath.stringByAppendingPathComponent("unzippedData/UserDatabase.sqlite")
        let destinationPath = documentsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
        if fileManager.moveItemAtPath(tempPath, toPath: destinationPath, error: &error) != true
        {
            println("Replace database error: \(error)")
        }
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
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func notifyCompletion(message: String, completion: (block: Bool) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)

        self.presentViewController(alertController, animated: true) { () -> Void in }
        
        let delay = 2.0 * Double(NSEC_PER_SEC) // # of seconds to show Alert
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.deleteFile("Inbox/file.zip") // removes the zip file that was imported
                self.deleteFile("unzippedData") // removes the unzipped data directory if it exists
                completion(block: true)
            })
        })
    }
    
}