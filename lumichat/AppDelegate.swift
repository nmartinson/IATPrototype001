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
		var array1 = [1, "Expressions", "expressions"]
		var array2 = [2, "Social", "social"]
		var array3 = [3, "Entertainment", "entertainment"]
		var array4 = [4, "Compliments", "compliments"]
		
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
		let docsPath: String = paths
		let path = docsPath.stringByAppendingPathComponent("UserDatabase.sqlite")
		let database = FMDatabase(path: path)
		database.open()
		
//		If there three lines are uncommented then the three DB tables will be deleted and then recreated with stock values
//		database.executeUpdate("DROP TABLE categories", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE social", withArgumentsInArray: nil)
//		database.executeUpdate("DROP TABLE expressions", withArgumentsInArray: nil)

		if(!database.tableExists("categories"))
		{
			database.executeUpdate("CREATE TABLE categories(position int primary key, cell text, link text)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO categories(position, cell, link) values(?, ?, ?)", withArgumentsInArray: array1)
			database.executeUpdate("INSERT INTO categories(position, cell, link) values(?, ?, ?)", withArgumentsInArray: array2)
			database.executeUpdate("INSERT INTO categories(position, cell, link) values(?, ?, ?)", withArgumentsInArray: array3)
			database.executeUpdate("INSERT INTO categories(position, cell, link) values(?, ?, ?)", withArgumentsInArray: array4)
		
		
			var link1 = [0, "Im Hungry", "", "buttonTest.jpg", 0]
			var link2 = [1, "Im Thirsty", "",  "buttonTest.jpg", 0]
			var link3 = [2, "Im Tired", "", "buttonTest.jpg", 0]
			var link4 = [3, "Please Help Me", "", "buttonTest.jpg", 0]
			var link5 = [4, "Im Hungry", "", "buttonTest.jpg", 0]
//			database.executeUpdate("DROP TABLE \(link)", withArgumentsInArray: nil)
			database.executeUpdate("CREATE TABLE IF NOT EXISTS expressions(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link3)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link4)
			database.executeUpdate("INSERT INTO expressions(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link5)


			link1 = [0, "Hello", "", "buttonTest.jpg", 0]
			link2 = [1, "Goodbye", "", "buttonTest.jpg", 0]
			database.executeUpdate("CREATE TABLE IF NOT EXISTS social(number INT primary key, title TEXT, description TEXT, image TEXT, presses INT)", withArgumentsInArray: nil)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link1)
			database.executeUpdate("INSERT INTO social(number, title, description, image, presses) values(?,?,?,?,?)", withArgumentsInArray: link2)
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

