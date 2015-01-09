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
    
    override func viewDidLoad()
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        var inboxPath = documentsPath.stringByAppendingPathComponent("Inbox")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(inboxPath, error: nil) as [String]
        
        println("directory contents \(directoryContents)")
    }
    
    
    @IBAction func overwriteButtonPressed(sender: AnyObject)
    {
        deleteFile("UserDatabase.sqlite") // delete old database
        replaceDatabase() // moves new database into place
        
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
    
    func replaceDatabase()
    {
        var error:NSError?
        let fileManager = NSFileManager()
        let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let tempPath = documentsPath.stringByAppendingPathComponent("Inbox/UserDatabase.sqlite")
        let destinationPath = documentsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
        if fileManager.moveItemAtPath(tempPath, toPath: destinationPath, error: &error) != true
        {
            println("Error: \(error)")
        }
    }
    
    func deleteFileAtURL(url: NSURL)
    {
        let fileManager = NSFileManager()
        var error:NSError?
        fileManager.removeItemAtURL(url, error: &error)
        if error != nil
        {
            println("Error: \(error)")
        }
    }
    
    func deleteFile(path: String)
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let filePath = documentsPath.stringByAppendingPathComponent("Inbox/\(path)")
        let fileManager = NSFileManager()
        var error:NSError?
        fileManager.removeItemAtPath(filePath, error: &error)
        if error != nil
        {
            println("Error: \(error)")
        }

    }
}