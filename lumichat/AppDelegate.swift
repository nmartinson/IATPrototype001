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


	/* *******************************************************************************************************************
	*	This is the very fist method to be called within the app that we have access to.
	******************************************************************************************************************* */
	func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
	{
        
		// Setup stock database
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
		let docsPath: String = paths
		let path = docsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
		let database = FMDatabase(path: path)
		database.open()
		
//		If there three lines are uncommented then the three DB tables will be deleted and then recreated with stock values
//		database.executeUpdate("DROP TABLE categories", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE social", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE expressions", withArgumentsInArray: nil)
//        database.executeUpdate("DROP TABLE pain_scale", withArgumentsInArray: nil)
//        database.executeUpdate("DROP TABLE body_parts", withArgumentsInArray: nil)
        
		if(!database.tableExists("categories"))
		{
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let imagePath = documentDirectory.stringByAppendingPathComponent("buttonTest.jpg")
            let data = UIImageJPEGRepresentation(UIImage(named: "buttonTest.jpg"), 1)
            data.writeToFile(imagePath, atomically: true)
            // categories
            var link1 = [0, "Expressions", "expressions", imagePath, 0]
            var link2 = [1, "Social", "social",  imagePath, 0]
            var link3 = [2, "Entertainment", "entertainment", imagePath, 0]
            var link4 = [3, "Compliments", "compliments", imagePath, 0]
            var link5 = [4, "Pain Scale", "pain_scale", imagePath, 0]
            var link6 = [5, "Body Parts", "body_parts", imagePath, 0]
//			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
            database.executeUpdate("CREATE TABLE IF NOT EXISTS categories(number INT primary key, title TEXT, link TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)
            database.executeUpdate("INSERT INTO categories(number, title, link, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link6)

//   			database.executeUpdate("DROP TABLE entertainment", withArgumentsInArray: nil)

		
            // expressions
			link1 = [0, "Im Hungry", "", imagePath, 0]
			link2 = [1, "Im Thirsty", "",  imagePath, 0]
			link3 = [2, "Im Tired", "", imagePath, 0]
			link4 = [3, "Please Help Me", "", imagePath, 0]
			link5 = [4, "Im Hungry", "", imagePath, 0]
//			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE IF NOT EXISTS expressions(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)

            // social
			link1 = [0, "Hello", "", imagePath, 0]
			link2 = [1, "Goodbye", "", imagePath, 0]
			database.executeUpdate("CREATE TABLE IF NOT EXISTS social(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
            
            //Body parts
            link1 = [0, "Head", "My head hurts", imagePath, 0]
            link2 = [1, "Hand", "My hand hurts",  imagePath, 0]
            link3 = [2, "Foot", "My foot hurts", imagePath, 0]
            link4 = [3, "Arm", "My arm hurts", imagePath, 0]
            link5 = [4, "Ear", "My ear hurts", imagePath, 0]
            link6 = [5, "Eye", "My eye hurts", imagePath, 0]
            var link7 = [6, "Mouth", "My mouth hurts",  imagePath, 0]
            var link8 = [7, "Throat", "My throat hurts", imagePath, 0]
            var link9 = [8, "Back", "My back hurts", imagePath, 0]
            var link10 = [9, "Leg", "My leg hurts", imagePath, 0]
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
            link1 = [0, "1", "My pain is at level 1", imagePath, 0]
            link2 = [1, "2", "My pain is at level 2",  imagePath, 0]
            link3 = [2, "3", "My pain is at level 3", imagePath, 0]
            link4 = [3, "4", "My pain is at level 4", imagePath, 0]
            link5 = [4, "5", "My pain is at level 5", imagePath, 0]
            link6 = [5, "6", "My pain is at level 6", imagePath, 0]
            link7 = [6, "7", "My pain is at level 7",  imagePath, 0]
            link8 = [7, "8", "My pain is at level 8", imagePath, 0]
            link9 = [8, "9", "My pain is at level 9", imagePath, 0]
            link10 = [9, "10", "My pain is at level 10", imagePath, 0]
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
		}
		database.close()
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

