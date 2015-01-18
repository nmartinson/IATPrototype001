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

	/* *******************************************************************************************************************
	*	This is the very fist method to be called within the app that we have access to.
	******************************************************************************************************************* */
	func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
	{
        let utilObject = Util()
        let coreDataObject = CoreDataController()

        utilObject.createDirectory("images/user")
        
        var image = UIImage(named: "buttonTest.jpg")
        var buttonTest = utilObject.saveImage(image, title: "buttonTest")
        image = UIImage(named: "1.jpg")
        var one = utilObject.saveImage(image, title: "1")
        image = UIImage(named: "2.jpg")
        var two = utilObject.saveImage(image, title: "2")
        image = UIImage(named: "3.jpg")
        var three = utilObject.saveImage(image, title: "3")
        image = UIImage(named: "4.jpg")
        var four = utilObject.saveImage(image, title: "4")
        image = UIImage(named: "5.jpg")
        var five = utilObject.saveImage(image, title: "5")
        image = UIImage(named: "6.jpg")
        var six = utilObject.saveImage(image, title: "6")
        image = UIImage(named: "7.jpg")
        var seven = utilObject.saveImage(image, title: "7")
        image = UIImage(named: "8.jpg")
        var eight = utilObject.saveImage(image, title: "8")
        image = UIImage(named: "9.jpg")
        var nine = utilObject.saveImage(image, title: "9")
        image = UIImage(named: "10.jpg")
        var ten = utilObject.saveImage(image, title: "10")
        image = UIImage(named: "oops.jpg")
        var oops = utilObject.saveImage(image, title: "oops")
        image = UIImage(named: "no.jpg")
        var no = utilObject.saveImage(image, title: "no")
        image = UIImage(named: "yes.jpg")
        var yes = utilObject.saveImage(image, title: "yes")
        image = UIImage(named: "maybe.jpg")
        var maybe = utilObject.saveImage(image, title: "maybe")
        image = UIImage(named: "arm.jpg")
        var arm = utilObject.saveImage(image, title: "arm")
        image = UIImage(named: "back.jpg")
        var back = utilObject.saveImage(image, title: "back")
        image = UIImage(named: "ear.jpg")
        var ear = utilObject.saveImage(image, title: "ear")
        image = UIImage(named: "eye.jpg")
        var eye = utilObject.saveImage(image, title: "eye")
        image = UIImage(named: "foot.jpg")
        var foot = utilObject.saveImage(image, title: "foot")
        image = UIImage(named: "hand.jpg")
        var hand = utilObject.saveImage(image, title: "hand")
        image = UIImage(named: "head.jpg")
        var head = utilObject.saveImage(image, title: "head")
        image = UIImage(named: "later.jpg")
        var later = utilObject.saveImage(image, title: "later")
        image = UIImage(named: "leg.jpg")
        var leg = utilObject.saveImage(image, title: "leg")
        image = UIImage(named: "mouth.jpg")
        var mouth = utilObject.saveImage(image, title: "mouth")
        image = UIImage(named: "throat.jpg")
        var throat = utilObject.saveImage(image, title: "throat")
        
        let (success, categoriesArray) = coreDataObject.getCategories()
        if !success
        {
            coreDataObject.createInManagedObjectContextCategories("Expressions", image: buttonTest, link: "Expressions", presses: 0)
            coreDataObject.createInManagedObjectContextCategories("Social", image: buttonTest, link: "Social", presses: 0)
            coreDataObject.createInManagedObjectContextCategories("Body Parts", image: buttonTest, link: "BodyParts", presses: 0)
            coreDataObject.createInManagedObjectContextCategories("Pain Scale", image: buttonTest, link: "PainScale", presses: 0)
            coreDataObject.createInManagedObjectContextCategories("Yes No Maybe", image: buttonTest, link: "YesNoMaybe", presses: 0)
            
            coreDataObject.createInManagedObjectContextTable("Head", image: head, longDescription: "My head hurts", entity: "Tables", table: "BodyParts", index: 0)
            coreDataObject.createInManagedObjectContextTable("Hand", image: hand, longDescription: "My hand hurts", entity: "Tables", table: "BodyParts", index: 1)
            coreDataObject.createInManagedObjectContextTable("Foot", image: foot, longDescription: "My foot hurts", entity: "Tables", table: "BodyParts", index: 2)
            coreDataObject.createInManagedObjectContextTable("Arm", image: arm, longDescription: "My arm hurts", entity: "Tables", table: "BodyParts", index: 3)
            coreDataObject.createInManagedObjectContextTable("Ear", image: ear, longDescription: "My ear hurts", entity: "Tables", table: "BodyParts", index: 4)
            coreDataObject.createInManagedObjectContextTable("Eye", image: eye, longDescription: "My eye hurts", entity: "Tables", table: "BodyParts", index: 5)
            coreDataObject.createInManagedObjectContextTable("Mouth", image: mouth, longDescription: "My mouth hurts", entity: "Tables", table: "BodyParts", index: 6)
            coreDataObject.createInManagedObjectContextTable("Throat", image: throat, longDescription: "My throat hurts", entity: "Tables", table: "BodyParts", index: 7)
            coreDataObject.createInManagedObjectContextTable("Back", image: back, longDescription: "My back hurts", entity: "Tables", table: "BodyParts", index: 8)
            coreDataObject.createInManagedObjectContextTable("Leg", image: leg, longDescription: "My leg hurts", entity: "Tables", table: "BodyParts", index: 9)
            
            coreDataObject.createInManagedObjectContextTable("Yes", image: yes, longDescription: "", entity: "Tables", table: "YesNoMaybe", index: 0)
            coreDataObject.createInManagedObjectContextTable("No", image: no, longDescription: "", entity: "Tables", table: "YesNoMaybe", index: 1)
            coreDataObject.createInManagedObjectContextTable("Maybe", image: maybe, longDescription: "", entity: "Tables", table: "YesNoMaybe", index: 2)
            
            coreDataObject.createInManagedObjectContextTable("Im Hungry", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions", index: 0)
            coreDataObject.createInManagedObjectContextTable("Im Thirsty", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions", index: 1)
            coreDataObject.createInManagedObjectContextTable("Im Tired", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions", index: 2)
            coreDataObject.createInManagedObjectContextTable("Please Help Me", image: buttonTest, longDescription: "", entity: "Tables", table: "Expressions", index: 3)
            
            coreDataObject.createInManagedObjectContextTable("Hello", image: buttonTest, longDescription: "", entity: "Tables", table: "Social", index: 0)
            coreDataObject.createInManagedObjectContextTable("Goodbye", image: buttonTest, longDescription: "", entity: "Tables", table: "Social", index: 1)
            
            coreDataObject.createInManagedObjectContextTable("1", image: one, longDescription: "My pain is at level 1", entity: "Tables", table: "PainScale", index: 0)
            coreDataObject.createInManagedObjectContextTable("2", image: two, longDescription: "My pain is at level 2", entity: "Tables", table: "PainScale", index: 1)
            coreDataObject.createInManagedObjectContextTable("3", image: three, longDescription: "My pain is at level 3", entity: "Tables", table: "PainScale", index: 2)
            coreDataObject.createInManagedObjectContextTable("4", image: four, longDescription: "My pain is at level 4", entity: "Tables", table: "PainScale", index: 3)
            coreDataObject.createInManagedObjectContextTable("5", image: five, longDescription: "My pain is at level 5", entity: "Tables", table: "PainScale", index: 4)
            coreDataObject.createInManagedObjectContextTable("6", image: six, longDescription: "My pain is at level 6", entity: "Tables", table: "PainScale", index: 5)
            coreDataObject.createInManagedObjectContextTable("7", image: seven, longDescription: "My pain is at level 7", entity: "Tables", table: "PainScale", index: 6)
            coreDataObject.createInManagedObjectContextTable("8", image: eight, longDescription: "My pain is at level 8", entity: "Tables", table: "PainScale", index: 7)
            coreDataObject.createInManagedObjectContextTable("9", image: nine, longDescription: "My pain is at level 9", entity: "Tables", table: "PainScale", index: 8)
            coreDataObject.createInManagedObjectContextTable("10", image: ten, longDescription: "My pain is at level 10", entity: "Tables", table: "PainScale", index: 9)
        }

        return true
	}

    /* ***********************************************************************************************
    *   Gets called when the user opens a zip file outside of the application
    *************************************************************************************************/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialView = storyboard.instantiateViewControllerWithIdentifier("OpenFileController") as OpenFileViewController
        initialView.url = url
        window?.rootViewController?.presentViewController(initialView, animated: true, completion: { () -> Void in })

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
//        self.saveContext()
	}
    

    

}

