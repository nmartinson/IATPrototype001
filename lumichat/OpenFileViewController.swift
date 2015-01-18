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
        var database = db.getDB("unzippedData/lumichat.sqlite")
        database.open()
        
        //Get all the categories in the old DB
        let (success, categories) = coreDataObject.getCategories()
        var importDBResults = database.executeQuery("SELECT * FROM ZCATEGORIES",withArgumentsInArray: nil)
        
        for category in categories!
        {
            oldDBTitles.append(category.title)
        }
        
        while( importDBResults.next() )
        {
            importDBTitles.append(importDBResults.stringForColumn("ztitle") as String!)
            importTables.append(importDBResults.stringForColumn("zlink") as String!)
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
                println("found a missing title")
                // insert import row into old.....i holds index of categorie that needs inserted
                var array = []
                importDBResults = database.executeQuery("SELECT * FROM zcategories WHERE ztitle=?", withArgumentsInArray: [importDBTitles[i]])
            
                importDBResults.next()
                var number:Int = Int(importDBResults.intForColumn("znumber"))
                let title = importDBResults.stringForColumn("ztitle")
                let link = importDBResults.stringForColumn("zlink")
                let image = importDBResults.stringForColumn("zimage")
                let presses:Int = Int(importDBResults.intForColumn("zpresses"))
                
                array = [number, title, link, image, presses]
                
                coreDataObject.createInManagedObjectContextCategories(title, image: image, link: link, presses: 0)
            }
            foundMatch = false // reset value for next loop
        }
        database.closeOpenResultSets()
        database.clearCachedStatements()
        database.close()
        
        //
        // Goes through every table and inserts rows if they arent present
        foundMatch = false
        database = db.getDB("unzippedData/lumichat.sqlite")
        database.open()
        for(var i = 0; i < importTables.count; i++)
        {
            oldDBTitles.removeAll(keepCapacity: false)
            importDBTitles.removeAll(keepCapacity: false)

            let (success, table) = coreDataObject.getTables(importTables[i])
            if success
            {
                for row in table!
                {
                    oldDBTitles.append(row.title)
                }
            }

            if database.tableExists("ZTables")
            {
                importDBResults = database.executeQuery("SELECT * FROM ztables WHERE ztable = ?", withArgumentsInArray: [importTables[i]])
                database.clearCachedStatements()
            }

            while( importDBResults.next() )
            {
                importDBTitles.append(importDBResults.stringForColumn("ztitle") as String!)
            }

            
            // inserts into the category table any categories that are in the import DB but not the old DB
            foundMatch = false
            var indexNumber = oldDBTitles.count
            for(var i = 0; i < importDBTitles.count; i++)
            {
                for(var j = 0; j < oldDBTitles.count; j++)
                {
                    if( (importDBTitles[i] == oldDBTitles[j]) && importDBTitles[i] != "")
                    {
                        foundMatch = true
                    }
                }
                if foundMatch == false
                {
                    // insert import row into old.....i holds index of categorie that needs inserted
                    var array = []

                    if database.open()
                    {
                        importDBResults = database.executeQuery("SELECT ztitle,zlongDescription,zimage,ztable FROM ztables WHERE ztitle=?", withArgumentsInArray: [importDBTitles[i]])
                    }
                    while( importDBResults.next() && importDBResults != nil)
                    {
                        indexNumber++
                        let title = importDBResults.stringForColumn("ztitle")
                        let longDescription = importDBResults.stringForColumn("zlongDescription")
                        let image = importDBResults.stringForColumn("zimage")
                        let table = importDBResults.stringForColumn("ztable")
                        
                        array = [indexNumber, title, longDescription, image, 0]
                        
                        coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, entity: "Tables", table: table, index: indexNumber)
                    }
                }
                foundMatch = false // reset value for next loop
            }
        }
        database.close()
        deleteFile("unzippedData/lumichat.sqlite") // delete old database
        moveImages()
        notifyCompletion("Merge Complete!", completion: { (block) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        })

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