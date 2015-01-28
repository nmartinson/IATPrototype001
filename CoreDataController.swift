//
//  CoreDataController.swift
//  lumichat
//
//  Created by Nick Martinson on 1/13/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController:NSObject //NSFetchedResultsController
{
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("UserDatabase", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("lumichat.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Turn off WAL journal mode
        var options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true, NSSQLitePragmasOption: ["journal_mode": "DELETE"]]

        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    
    /* ************************************************************************************************
    *
    ************************************************************************************************ */
    func getCategories() -> (Bool, [Categories]?)
    {
        var categoryTable = [Categories]()
        let fetchRequest = NSFetchRequest(entityName: "Categories")
        if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Categories] {
            if fetchResults.count > 0
            {
                categoryTable = fetchResults
                return (true, categoryTable)
            }
        }
        return (false, nil)
    }
    
    func getPhrases() -> NSArray?
    {
        var phraseTable:NSMutableArray = []
        let fetchRequest = NSFetchRequest(entityName: "Phrases")
        let sortDescriptor = NSSortDescriptor(key: "presses", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Phrases]{
            if fetchResults.count > 0
            {
                for item in fetchResults
                {
                    phraseTable.addObject(item.text)
                }
                return phraseTable
            }
        }
        return []
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getTables(tableName: String) -> (Bool, [Tables]?)
    {
        var table = [Tables]()
        let fetchRequest = NSFetchRequest(entityName: "Tables")
        let predicate = NSPredicate(format: "table == %@", tableName)
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.predicate = predicate
        if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Tables] {
            if fetchResults.count > 0
            {
                table = fetchResults
                return (true, table)
            }
        }
        return (false, nil)
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getButtonWithTitle(title: String) -> (Bool, [Tables]?)
    {
        var button = [Tables]()
        let fetchRequest = NSFetchRequest(entityName: "Tables")
        let predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.predicate = predicate
        if let fetchResult = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Tables] {
            if fetchResult.count > 0
            {
                button = fetchResult
                return (true, button)
            }
        }
        return (false, nil)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func updateButtonWith(oldTitle: String, newTitle: String, longDescription: String, image: String)
    {
        let (success, buttons) = getButtonWithTitle(oldTitle)
        if let button = buttons?[0]{
            button.title = newTitle
            button.longDescription = longDescription
            if image != ""
            {
                button.image = image
            }
            saveContext()
        }
        
    }
    
    
    func getPhraseWithText(text: String) -> Phrases
    {
        var phrase:Phrases?
        let fetchRequest = NSFetchRequest(entityName: "Phrases")
        let predicate = NSPredicate(format: "text == %@", text)
        fetchRequest.predicate = predicate
        if let fetchResult = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [Phrases] {
            if fetchResult.count > 0
            {
                phrase = fetchResult[0]
            }
        }
        return phrase!
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func incrementPressCountForPhrase(text: String)
    {
        var phrase = getPhraseWithText(text)
        phrase.presses = Int(phrase.presses) + 1
        saveContext()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func deleteButtonWithTitle(title: String)
    {
        let (success, buttons) = getButtonWithTitle(title)
        if let button = buttons?[0]{
            managedObjectContext?.deleteObject(button)
            saveContext()
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createInManagedObjectContextCategories(title: String, image: String, link: String, presses: Int) -> Categories
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Categories", inManagedObjectContext: self.managedObjectContext!) as Categories
        newItem.title = title
        newItem.link = link
        newItem.image = image
        newItem.presses = presses
        saveContext()
        
        return newItem
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createInManagedObjectContextTable(title: String, image: String, longDescription: String, entity: String, table: String, index: Int)
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName(entity, inManagedObjectContext: self.managedObjectContext!) as Tables
        newItem.title = title
        newItem.image = image
        newItem.presses = 0
        newItem.table = table
        newItem.longDescription = longDescription
        newItem.index = index
        saveContext()
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createInManagedObjectContextPhrase(text: String)
    {
        let newPhrase = NSEntityDescription.insertNewObjectForEntityForName("Phrases", inManagedObjectContext: self.managedObjectContext!) as Phrases
        newPhrase.text = text
        newPhrase.presses = 0
        saveContext()
    }
    

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func deleteTableFromContext(tableName: String)
    {
        let (success, table) = getTables(tableName)
        var IDs:[NSManagedObjectID]?
        if success
        {
            for item in table!
            {
                managedObjectContext?.deleteObject(item)
            }
            saveContext()
        }
    }
    
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func coreDataToJSON(managaedObject: NSManagedObject)
    {
        var fields:NSMutableDictionary?
        for attribute in managaedObject.entity.properties
        {
            var attributeName = attribute.name
            println("attribute name \(attributeName)")
            var attributeValue = managaedObject.valueForKey(attributeName)
            println("attribute value \(attributeValue)")
            fields?.setObject(attributeValue!, forKey: attributeName)
        }
    }
    
    
    
    
    
    
}