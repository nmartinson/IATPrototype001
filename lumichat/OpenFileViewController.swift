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
        
        Util().createDirectory("unzippedData") // create directory to unzip file to
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
        
        Util().deleteFile("lumichat.sqlite") // delete old database
        replaceDatabase() // moves new database into place
        Util().createDirectory("images/user")
        Util().moveImages()
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
                // insert import row into old.....i holds index of categorie that needs inserted
                importDBResults = database.executeQuery("SELECT * FROM zcategories WHERE ztitle=?", withArgumentsInArray: [importDBTitles[i]])
            
                importDBResults.next()
                var number:Int = Int(importDBResults.intForColumn("znumber"))
                let title = importDBResults.stringForColumn("ztitle")
                let link = importDBResults.stringForColumn("zlink")
                let image = importDBResults.stringForColumn("zimage")
                let presses:Int = Int(importDBResults.intForColumn("zpresses"))
                
//                coreDataObject.createInManagedObjectContextCategories(title, image: image, link: link, presses: 0)
            }
            foundMatch = false // reset value for next loop
        }
        database.closeOpenResultSets()
        database.clearCachedStatements()
        database.close()
        
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
                    if database.open()
                    {
                        // select properties for the title that is missing in Core Data
                        importDBResults = database.executeQuery("SELECT ztitle,zlongDescription,zimage,ztable FROM ztables WHERE ztitle=?", withArgumentsInArray: [importDBTitles[i]])
                    }
                    while( importDBResults.next() && importDBResults != nil)
                    {
                        indexNumber++
                        let title = importDBResults.stringForColumn("ztitle")
                        let longDescription = importDBResults.stringForColumn("zlongDescription")
                        let image = importDBResults.stringForColumn("zimage")
                        let table = importDBResults.stringForColumn("ztable")
                        
                        // insert the new button into Core Data
                        coreDataObject.createInManagedObjectContextTable(title, image: image, longDescription: longDescription, table: table, index: indexNumber, linkedPage: "")
                    }
                }
                foundMatch = false // reset value for next loop
            }
        }
        database.close()
        Util().deleteFile("unzippedData/lumichat.sqlite") // delete old database
        Util().moveImages() // move new images into place
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
    func notifyCompletion(message: String, completion: (block: Bool) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)

        self.presentViewController(alertController, animated: true) { () -> Void in }
        
        let delay = 2.0 * Double(NSEC_PER_SEC) // # of seconds to show Alert
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                Util().deleteFile("Inbox/file.zip") // removes the zip file that was imported
                Util().deleteFile("unzippedData") // removes the unzipped data directory if it exists
                completion(block: true)
            })
        })
    }
    
}