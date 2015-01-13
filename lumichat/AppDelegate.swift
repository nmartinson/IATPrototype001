//  AppDelegate.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/8/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//
//	This class is the entry point into the app and is the first thing to get called. As of now
//	it is responsible for the intial DB setup so that there is a default DB for testing with.

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?
    var editMode = false


    /* *******************************************************************************************************
    *	Saves image to a new 'image' directory in the Documents directory.
    ******************************************************************************************************* */
    func saveImage(image: UIImage?, title: String) -> String
    {
        if (image != nil)
        {
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
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

	/* *******************************************************************************************************************
	*	This is the very fist method to be called within the app that we have access to.
	******************************************************************************************************************* */
	func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
	{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String


        createDirectory("images/user")

            var image = UIImage(named: "buttonTest.jpg")
            var buttonTest = saveImage(image, title: "buttonTest")
            image = UIImage(named: "1.jpg")
            var one = saveImage(image, title: "1")
            image = UIImage(named: "2.jpg")
            var two = saveImage(image, title: "2")
            image = UIImage(named: "3.jpg")
            var three = saveImage(image, title: "3")
            image = UIImage(named: "4.jpg")
            var four = saveImage(image, title: "4")
            image = UIImage(named: "5.jpg")
            var five = saveImage(image, title: "5")
            image = UIImage(named: "6.jpg")
            var six = saveImage(image, title: "6")
            image = UIImage(named: "7.jpg")
            var seven = saveImage(image, title: "7")
            image = UIImage(named: "8.jpg")
            var eight = saveImage(image, title: "8")
            image = UIImage(named: "9.jpg")
            var nine = saveImage(image, title: "9")
            image = UIImage(named: "10.jpg")
            var ten = saveImage(image, title: "10")
            image = UIImage(named: "oops.jpg")
            var oops = saveImage(image, title: "oops")
            image = UIImage(named: "no.jpg")
            var no = saveImage(image, title: "no")
            image = UIImage(named: "yes.jpg")
            var yes = saveImage(image, title: "yes")
            image = UIImage(named: "maybe.jpg")
            var maybe = saveImage(image, title: "maybe")
            image = UIImage(named: "arm.jpg")
            var arm = saveImage(image, title: "arm")
            image = UIImage(named: "back.jpg")
            var back = saveImage(image, title: "back")
            image = UIImage(named: "ear.jpg")
            var ear = saveImage(image, title: "ear")
            image = UIImage(named: "eye.jpg")
            var eye = saveImage(image, title: "eye")
            image = UIImage(named: "foot.jpg")
            var foot = saveImage(image, title: "foot")
            image = UIImage(named: "hand.jpg")
            var hand = saveImage(image, title: "hand")
            image = UIImage(named: "head.jpg")
            var head = saveImage(image, title: "head")
            image = UIImage(named: "later.jpg")
            var later = saveImage(image, title: "later")
            image = UIImage(named: "leg.jpg")
            var leg = saveImage(image, title: "leg")
            image = UIImage(named: "mouth.jpg")
            var mouth = saveImage(image, title: "mouth")
            image = UIImage(named: "throat.jpg")
            var throat = saveImage(image, title: "throat")
        
        let (success, categoriesArray) = getCategories()
        if !success
        {
            createInManagedObjectContextCategories(self.managedObjectContext!, title: "Expressions", image: buttonTest, link: "Expressions", presses: 0)
            createInManagedObjectContextCategories(self.managedObjectContext!, title: "Social", image: buttonTest, link: "Social", presses: 0)
            createInManagedObjectContextCategories(self.managedObjectContext!, title: "Body Parts", image: buttonTest, link: "BodyParts", presses: 0)
            createInManagedObjectContextCategories(self.managedObjectContext!, title: "Pain Scale", image: buttonTest, link: "PainScale", presses: 0)
            createInManagedObjectContextCategories(self.managedObjectContext!, title: "Yes No Maybe", image: buttonTest, link: "YesNoMaybe", presses: 0)
            
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Head", image: head, longDescription: "My head hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Hand", image: hand, longDescription: "My hand hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Foot", image: foot, longDescription: "My foot hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Arm", image: arm, longDescription: "My arm hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Ear", image: ear, longDescription: "My ear hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Eye", image: eye, longDescription: "My eye hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Mouth", image: mouth, longDescription: "My mouth hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Throat", image: throat, longDescription: "My throat hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Back", image: back, longDescription: "My back hurts", entity: "Tables", table: "BodyParts")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Leg", image: leg, longDescription: "My leg hurts", entity: "Tables", table: "BodyParts")
            
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Yes", image: yes, longDescription: "", entity: "Tables", table: "YesNoMaybe")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "No", image: no, longDescription: "", entity: "Tables", table: "YesNoMaybe")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Maybe", image: maybe, longDescription: "", entity: "Tables", table: "YesNoMaybe")
            
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Im Hungry", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Im Thirsty", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Im Tired", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Please Help Me", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions")
            
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Hello", image: buttonTest, longDescription: "", entity: "Tables", table: "Social")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "Goodbye", image: buttonTest, longDescription: "", entity: "Tables", table: "Social")
            
            createInManagedObjectContextTable(self.managedObjectContext!, title: "1", image: one, longDescription: "My pain is at level 1", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "2", image: two, longDescription: "My pain is at level 2", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "3", image: three, longDescription: "My pain is at level 3", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "4", image: four, longDescription: "My pain is at level 4", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "5", image: five, longDescription: "My pain is at level 5", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "6", image: six, longDescription: "My pain is at level 6", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "7", image: seven, longDescription: "My pain is at level 7", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "8", image: eight, longDescription: "My pain is at level 8", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "9", image: nine, longDescription: "My pain is at level 9", entity: "Tables", table: "PainScale")
            createInManagedObjectContextTable(self.managedObjectContext!, title: "10", image: ten, longDescription: "My pain is at level 10", entity: "Tables", table: "PainScale")
        }
        
		return true
	}

    
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

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createInManagedObjectContextCategories(moc: NSManagedObjectContext, title: String, image: String, link: String, presses: Int) -> Categories
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Categories", inManagedObjectContext: moc) as Categories
        newItem.title = title
        newItem.link = link
        newItem.image = image
        newItem.presses = presses
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
        
        return newItem
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createInManagedObjectContextTable(moc: NSManagedObjectContext, title: String, image: String, longDescription: String, entity: String, table: String)
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName(entity, inManagedObjectContext: moc) as Tables
        newItem.title = title
        newItem.image = image
        newItem.presses = 0
        newItem.table = table
        newItem.longDescription = longDescription
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error)
        {
            println("Error! \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    
    
    /* ***********************************************************************************************
    *   Gets called when the user opens a zip file outside of the application
    *************************************************************************************************/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
//        var storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var initialView = storyboard.instantiateViewControllerWithIdentifier("OpenFileController") as OpenFileViewController
//        initialView.url = url
//        window?.rootViewController?.presentViewController(initialView, animated: true, completion: { () -> Void in })
//        
        return true
    }
    
	func applicationWillResignActive(application: UIApplication!) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication!) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication!) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication!) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication!) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
	}
    
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
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
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
    
    // MARK: - Core Data Saving support
    
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
    *	Create a new directory to store the images in
    ************************************************************************************************ */
    func createDirectory(directory: String) -> String
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

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

