//
//  EditButtonViewController.swift
//  lumichat
//
//  Created by Nick Martinson on 11/29/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

class EditButtonController: ModifyButtonController
{
    var link:String = ""
    var db = DBController.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        populateFields()
        println("viewDidLoad")
    }
    
    
    func populateFields()
    {
        var database = db.getDB("UserDatabase.sqlite")
        database.open()
        var results = FMResultSet()
        
        // If a DB table exists for the current category, extract all the button information
        if(database.tableExists(link))
        {
            results = database.executeQuery("SELECT * FROM \(link) WHERE title=\" ",withArgumentsInArray: nil)
            
//            while( results.next() )
//            {
                buttonTitleField.text = results.stringForColumn("title") as String!
                textDescription.text = results.stringForColumn("description") as String!
                var image = results.stringForColumn("image")
                buttonImage.image = loadImage(image)
//            }
        }
        database.close()
    }
    
    /* ************************************************************************************************
    *	Loads the specified image that is in the database for that button
    ************************************************************************************************ */
    func loadImage(title: String!) -> UIImage
    {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let imagePath = documentDirectory.stringByAppendingPathComponent(title)
        var image = UIImage(contentsOfFile: imagePath)
        
        return image!
    }
    
}