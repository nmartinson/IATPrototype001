//  AppDelegate.swift
//  DatabaseTable
//
//  Created by Nick Martinson on 8/8/14.
//  Copyright (c) 2014 BAapps. All rights reserved.
//
//	This class is the entry point into the app and is the first thing to get called. As of now
//	it is responsible for the intial DB setup so that there is a default DB for testing with.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?
    var editMode = false
    var db = DBController.sharedInstance


    /* *******************************************************************************************************
    *	Saves image to a new 'image' directory in the Documents directory.
    ******************************************************************************************************* */
    func saveImage(image: UIImage?, title: String) -> String
    {
        if (image != nil)
        {
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            var path = documentDirectory.stringByAppendingPathComponent("images") // append images to the directory string
            
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
            let imagePath = "images/\(title).jpg" // return only the path that is appended to the 'documents' path
            return imagePath
        }
        return ""
    }

	/* *******************************************************************************************************************
	*	This is the very fist method to be called within the app that we have access to.
	******************************************************************************************************************* */
	func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
	{
		// Setup stock database
        var database = db.getDB()
        database.open()
        
//		If there three lines are uncommented then the three DB tables will be deleted and then recreated with stock values
//		database.executeUpdate("DROP TABLE categories", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE social", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE expressions", withArgumentsInArray: nil)
//        database.executeUpdate("DROP TABLE pain_scale", withArgumentsInArray: nil)
//        database.executeUpdate("DROP TABLE body_parts", withArgumentsInArray: nil)
//        database.executeUpdate("DROP TABLE yes_no_maybe", withArgumentsInArray: nil)

		if(!database.tableExists("categories"))
		{
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

            
//            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//            let imagePath = documentDirectory.stringByAppendingPathComponent("buttonTest.jpg")
//            let data = UIImageJPEGRepresentation(UIImage(named: "buttonTest.jpg"), 1)
//            data.writeToFile(imagePath, atomically: true)
            // categories
            var link1 = [0, "Expressions", "expressions", buttonTest, 0]
            var link2 = [1, "Social", "social",  buttonTest, 0]
            var link3 = [2, "Entertainment", "entertainment", buttonTest, 0]
            var link4 = [3, "Compliments", "compliments", buttonTest, 0]
            var link5 = [4, "Pain Scale", "pain_scale", buttonTest, 0]
            var link6 = [5, "Body Parts", "body_parts", buttonTest, 0]
            var link7 = [6, "Yes-No-Maybe", "yes_no_maybe", buttonTest, 0]
//			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
            database.executeUpdate("CREATE TABLE IF NOT EXISTS categories(number INT primary key, title TEXT, link TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link6)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link7)

//   			database.executeUpdate("DROP TABLE entertainment", withArgumentsInArray: nil)

		
            // expressions
			link1 = [0, "Im Hungry", "", buttonTest, 0]
			link2 = [1, "Im Thirsty", "",  buttonTest, 0]
			link3 = [2, "Im Tired", "", buttonTest, 0]
			link4 = [3, "Please Help Me", "", buttonTest, 0]
//			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE IF NOT EXISTS expressions(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)

            // social
			link1 = [0, "Hello", "", buttonTest, 0]
			link2 = [1, "Goodbye", "", buttonTest, 0]
			database.executeUpdate("CREATE TABLE IF NOT EXISTS social(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            
            //Body parts
            link1 = [0, "Head", "My head hurts", head, 0]
            link2 = [1, "Hand", "My hand hurts",  hand, 0]
            link3 = [2, "Foot", "My foot hurts", foot, 0]
            link4 = [3, "Arm", "My arm hurts", arm, 0]
            link5 = [4, "Ear", "My ear hurts", ear, 0]
            link6 = [5, "Eye", "My eye hurts", eye, 0]
            link7 = [6, "Mouth", "My mouth hurts",  mouth, 0]
            var link8 = [7, "Throat", "My throat hurts", throat, 0]
            var link9 = [8, "Back", "My back hurts", back, 0]
            var link10 = [9, "Leg", "My leg hurts", leg, 0]
            database.executeUpdate("CREATE TABLE IF NOT EXISTS body_parts(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link6)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link7)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link8)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link9)
            database.executeUpdate("INSERT INTO body_parts(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link10)
            
            //Pain Scale
            link1 = [0, "1", "My pain is at level 1", one, 0]
            link2 = [1, "2", "My pain is at level 2",  two, 0]
            link3 = [2, "3", "My pain is at level 3", three, 0]
            link4 = [3, "4", "My pain is at level 4", four, 0]
            link5 = [4, "5", "My pain is at level 5", five, 0]
            link6 = [5, "6", "My pain is at level 6", six, 0]
            link7 = [6, "7", "My pain is at level 7",  seven, 0]
            link8 = [7, "8", "My pain is at level 8", eight, 0]
            link9 = [8, "9", "My pain is at level 9", nine, 0]
            link10 = [9, "10", "My pain is at level 10", ten, 0]
            database.executeUpdate("CREATE TABLE IF NOT EXISTS pain_scale(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link6)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link7)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link8)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link9)
            database.executeUpdate("INSERT INTO pain_scale(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link10)
            
            // yes-no-maybe
            link1 = [0, "Yes", "", yes, 0]
            link2 = [1, "No", "",  no, 0]
            link3 = [2, "Maybe", "", maybe, 0]
            database.executeUpdate("CREATE TABLE IF NOT EXISTS yes_no_maybe(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
            database.executeUpdate("INSERT INTO yes_no_maybe(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
            database.executeUpdate("INSERT INTO yes_no_maybe(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            database.executeUpdate("INSERT INTO yes_no_maybe(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)

            
		}
		database.close()
		return true
	}

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        var inboxPath = documentsPath.stringByAppendingPathComponent("Inbox")
        var directoryContents:[String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(inboxPath, error: nil) as [String]
        
        println("directory contents \(directoryContents)")
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
	}


}

