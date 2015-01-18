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
    var db = DBController.sharedInstance


    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    override func viewDidLoad()
    {
        let inboxPath = documentsPath.stringByAppendingPathComponent("Inbox")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(inboxPath, error: nil) as [String]
        println("directory contents \(directoryContents)")
    }
    
    func openZippedData()
    {
        let zip = Zipping()
        
        createDirectory("unzippedData") // create directory to unzip file to
        let sourcePath = documentsPath.stringByAppendingPathComponent("Inbox/file.zip")
        let destinationPath = documentsPath.stringByAppendingPathComponent("unzippedData")
        zip.unZipDirectory(sourcePath, destination: destinationPath)
        
        var error:NSError?
        fileManager.contentsOfDirectoryAtPath(destinationPath, error: &error) // check if the file was unzipped properly
        if error != nil
        {
            println("Unzipping error: \(error)")
        }
    }
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    @IBAction func overwriteButtonPressed(sender: AnyObject)
    {
        openZippedData()
        
        deleteFile("lumichat.sqlite") // delete old database
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
        openZippedData()
        var coreDataObject = CoreDataController()
        
        // arrays to hold titles 
        var oldDBTitles:[String] = []
        var importDBTitles: [String] = []
        var importTables: [String] = []
        var database = db.getDB("lumichat.sqlite")

        //Get all the categories in the old DB
        let (success, categories) = coreDataObject.getCategories()
        var importDBResults = database.executeQuery("SELECT * FROM categories",withArgumentsInArray: nil)
        
        for category in categories!
        {
            oldDBTitles.append(category.title)
        }
        
        while( importDBResults.next() )
        {
            importDBTitles.append(importDBResults.stringForColumn("title") as String!)
            importTables.append(importDBResults.stringForColumn("link") as String!)
        }
        
        // inserts into the category table any categories that are in the import DB but not the old DB
        var foundMatch = false
        for(var i = 0; i < importDBTitles.count; i++)
        {
            for(var j = 0; j < oldDBTitles.count; j++)
            {
                if importDBTitles[i] == oldDBTitles[j]
                {
                    foundMatch = true
                }
            }
            if foundMatch == false
            {
                // insert import row into old.....i holds index of categorie that needs inserted
                var array = []
                importDBResults = database.executeQuery("SELECT * FROM categories WHERE title=?", withArgumentsInArray: [importDBTitles[i]])
            
                importDBResults.next()
                var number:Int = Int(importDBResults.intForColumn("number"))
                let title = importDBResults.stringForColumn("title")
                let link = importDBResults.stringForColumn("link")
                let image = importDBResults.stringForColumn("image")
                let presses:Int = Int(importDBResults.intForColumn("presses"))
                
                array = [number, title, link, image, presses]
                
//                db.currentDB!.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
                coreDataObject.createInManagedObjectContextCategories(title, image: image, link: link, presses: 0)
            }
            foundMatch = false // reset value for next loop
        }
        

//        
//        //
//        // Goes through every table and inserts rows if they arent present
//        foundMatch = false
//        for(var i = 0; i < importTables.count; i++)
//        {
//            oldDBTitles.removeAll(keepCapacity: false)
//            importDBTitles.removeAll(keepCapacity: false)
//
//            if db.currentDB!.tableExists(importTables[i])
//            {
//                oldDBResults = db.currentDB!.executeQuery("SELECT * FROM \(importTables[i])", withArgumentsInArray: nil)
//                db.currentDB!.clearCachedStatements()
//            }
//            if database.tableExists(importTables[i])
//            {
//                importDBResults = database.executeQuery("SELECT * FROM \(importTables[i])", withArgumentsInArray: nil)
//                database.clearCachedStatements()
//            }
//            
//            while( oldDBResults.next() )
//            {
//                oldDBTitles.append(oldDBResults.stringForColumn("title") as String!)
//            }
//            while( importDBResults.next() )
//            {
//                importDBTitles.append(importDBResults.stringForColumn("title") as String!)
//            }
//            database.closeOpenResultSets()
//            
//            // inserts into the category table any categories that are in the import DB but not the old DB
//            foundMatch = false
//            var indexNumber = oldDBTitles.count
//            for(var i = 0; i < importDBTitles.count; i++)
//            {
//                for(var j = 0; j < oldDBTitles.count; j++)
//                {
//                    if( (importDBTitles[i] == oldDBTitles[j]) && importDBTitles[i] != "")
//                    {
//                        foundMatch = true
//                    }
//                }
//                if foundMatch == false
//                {
//                    database.closeOpenResultSets()
//                    // insert import row into old.....i holds index of categorie that needs inserted
//                    var array = []
//
//                    if database.open()
//                    {
//                        importDBResults = database.executeQuery("SELECT title,longDescription,image FROM \(importTables[i]) WHERE title=?", withArgumentsInArray: [importDBTitles[i]])
//                        database.clearCachedStatements()
//                    }
//                    while( importDBResults.next() )
//                    {
//                        indexNumber++
//                        let title = importDBResults.stringForColumn("title")
//                        let longDescription = importDBResults.stringForColumn("longDescription")
//                        let image = importDBResults.stringForColumn("image")
//                        
//                        array = [indexNumber, title, longDescription, image, 0]
//                        
//                        if db.currentDB!.open()
//                        {
//                            db.currentDB!.executeUpdate("INSERT INTO \(importTables[i])(number, title, longDescription, image, presses) values(?,?,?,?,?)", withArgumentsInArray: array)
//                            db.currentDB!.clearCachedStatements()
//                        }
//                    }
//                    database.closeOpenResultSets()
//                }
//                foundMatch = false // reset value for next loop
//            }
//            
//        }

        
        
        
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
        let tempPath = documentsPath.stringByAppendingPathComponent("unzippedData/lumichat.sqlite")
        let destinationPath = documentsPath.stringByAppendingPathComponent("lumichat.sqlite")
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