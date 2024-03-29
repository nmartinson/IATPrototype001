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
    var inputAccessory:UIView?

    
	/* *******************************************************************************************************************
	*	This is the very fist method to be called within the app that we have access to.
	******************************************************************************************************************* */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        inputAccessory = inputView
        window?.backgroundColor = UIColor.whiteColor()
        var navigationAppearance = UINavigationBar.appearance()
//        navigationAppearance.tintColor = UIColor.blueColor() // set navbar text blue
        navigationAppearance.barTintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1) // set navbar white
//        navigationAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
     
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldBegan:", name: UITextFieldTextDidBeginEditingNotification, object: nil)
        
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
        image = UIImage(named: "throat.jpg")
        var throat = utilObject.saveImage(image, title: "throat")
        image = UIImage(named: "notes")
        var notes = utilObject.saveImage(image, title: "notes")
        image = UIImage(named: "mouth")
        var mouth = utilObject.saveImage(image, title: "mouth")
        
        image = UIImage(named: "bathroom")
        var bathroom = utilObject.saveImage(image, title: "bathroom")
        image = UIImage(named: "comeback")
        var comeback = utilObject.saveImage(image, title: "comeback")
        image = UIImage(named: "family")
        var family = utilObject.saveImage(image, title: "family")
        image = UIImage(named: "goodbye")
        var goodbye = utilObject.saveImage(image, title: "goodbye")
        image = UIImage(named: "holdmyhand")
        var holdmyhand = utilObject.saveImage(image, title: "holdmyhand")
        image = UIImage(named: "nurse")
        var nurse = utilObject.saveImage(image, title: "nurse")
        image = UIImage(named: "painmeds")
        var painmeds = utilObject.saveImage(image, title: "painmeds")
        image = UIImage(named: "rest")
        var rest = utilObject.saveImage(image, title: "rest")
        image = UIImage(named: "thanks")
        var thanks = utilObject.saveImage(image, title: "thanks")
        
        
        image = UIImage(named: "hungry")
        var hungry = utilObject.saveImage(image, title: "hungry")
        image = UIImage(named: "thirsty")
        var thirsty = utilObject.saveImage(image, title: "thirsty")
        image = UIImage(named: "bodyparts")
        var bodyparts = utilObject.saveImage(image, title: "bodyparts")
        image = UIImage(named: "pleasehelpme")
        var pleasehelp = utilObject.saveImage(image, title: "pleasehelpme")
        
        let (success, pagesArray) = coreDataObject.getPages()
        if !success
        {
            // set default scan rate and border width
            NSUserDefaults.standardUserDefaults().setInteger(3, forKey: "buttonBorderWidth")
            NSUserDefaults.standardUserDefaults().setFloat(0.5, forKey: "scanRate")
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "numberOfSwitches")

            coreDataObject.createInManagedObjectContextPage("Home")
            coreDataObject.createInManagedObjectContextPage("BodyParts")
            coreDataObject.createInManagedObjectContextPage("PainScale")
            coreDataObject.createInManagedObjectContextPage("Notes")
            coreDataObject.createInManagedObjectContextPage("Expressions")
            coreDataObject.createInManagedObjectContextPage("Phrases")
        
            coreDataObject.createInManagedObjectContextTable("Body Parts", image: bodyparts, longDescription: "", table: "Home", index: 0, linkedPage: "BodyParts")
            coreDataObject.createInManagedObjectContextTable("Pain Scale", image: five, longDescription: "", table: "Home", index: 1, linkedPage: "PainScale")
            coreDataObject.createInManagedObjectContextTable("Expressions", image: hungry, longDescription: "", table: "Home", index: 2, linkedPage: "Expressions")
            coreDataObject.createInManagedObjectContextTable("Phrases", image: nurse, longDescription: "", table: "Home", index: 3, linkedPage: "Phrases")
            coreDataObject.createInManagedObjectContextTable("Notes", image: notes, longDescription: "", table: "Home", index: 4, linkedPage: "Notes")
            
            coreDataObject.createInManagedObjectContextTable("1", image: one, longDescription: "My pain is at level 1", table: "PainScale", index: 0, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("2", image: two, longDescription: "My pain is at level 2", table: "PainScale", index: 1, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("3", image: three, longDescription: "My pain is at level 3", table: "PainScale", index: 2, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("4", image: four, longDescription: "My pain is at level 4", table: "PainScale", index: 3, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("5", image: five, longDescription: "My pain is at level 5", table: "PainScale", index: 4, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("6", image: six, longDescription: "My pain is at level 6", table: "PainScale", index: 5, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("7", image: seven, longDescription: "My pain is at level 7", table: "PainScale", index: 6, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("8", image: eight, longDescription: "My pain is at level 8", table: "PainScale", index: 7, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("9", image: nine, longDescription: "My pain is at level 9", table: "PainScale", index: 8, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("10", image: ten, longDescription: "My pain is at level 10", table: "PainScale", index: 9, linkedPage: "")
            
            coreDataObject.createInManagedObjectContextTable("Head", image: head, longDescription: "My head hurts", table: "BodyParts", index: 0, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Hand", image: hand, longDescription: "My hand hurts", table: "BodyParts", index: 1, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Foot", image: foot, longDescription: "My foot hurts", table: "BodyParts", index: 2, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Arm", image: arm, longDescription: "My arm hurts", table: "BodyParts", index: 3, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Ear", image: ear, longDescription: "My ear hurts", table: "BodyParts", index: 4, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Eye", image: eye, longDescription: "My eye hurts", table: "BodyParts", index: 5, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Mouth", image: mouth, longDescription: "My mouth hurts", table: "BodyParts", index: 6, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Throat", image: throat, longDescription: "My throat hurts", table: "BodyParts", index: 7, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Back", image: back, longDescription: "My back hurts", table: "BodyParts", index: 8, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Leg", image: leg, longDescription: "My leg hurts", table: "BodyParts", index: 9, linkedPage: "")

            coreDataObject.createInManagedObjectContextTable("Yes", image: yes, longDescription: "", table: "YesNoMaybe", index: 0, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("No", image: no, longDescription: "", table: "YesNoMaybe", index: 1, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Maybe", image: maybe, longDescription: "", table: "YesNoMaybe", index: 2, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Later", image: later, longDescription: "", table: "YesNoMaybe", index: 3, linkedPage: "")

            coreDataObject.createInManagedObjectContextTable("Im Hungry", image: hungry, longDescription: "", table: "Expressions", index: 0, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Im Thirsty", image: thirsty, longDescription: "", table: "Expressions", index: 1, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Im Tired", image: rest, longDescription: "", table: "Expressions", index: 2, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Please Help Me", image: pleasehelp, longDescription: "", table: "Expressions", index: 3, linkedPage: "")
            
            coreDataObject.createInManagedObjectContextTable("Bathroom", image: bathroom, longDescription: "I need to go to the bathroom", table: "Phrases", index: 0, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Come back", image: comeback, longDescription: "Please come back", table: "Phrases", index: 1, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Family", image: family, longDescription: "I would like to see my family", table: "Phrases", index: 2, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Goodbye", image: goodbye, longDescription: "Good bye", table: "Phrases", index: 3, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Hold my hand", image: holdmyhand, longDescription: "Please hold my hand", table: "Phrases", index: 4, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Nurse", image: nurse, longDescription: "Please get my nurse", table: "Phrases", index: 5, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Pain Meds", image: painmeds, longDescription: "I need something for pain", table: "Phrases", index: 6, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Rest", image: rest, longDescription: "I need to rest", table: "Phrases", index: 7, linkedPage: "")
            coreDataObject.createInManagedObjectContextTable("Thanks", image: thanks, longDescription: "Thank you", table: "Phrases", index: 8, linkedPage: "")
        }
        
        return true
	}

    /* ***********************************************************************************************
    *   Gets called when the user opens a zip file outside of the application
    *************************************************************************************************/
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialView = storyboard.instantiateViewControllerWithIdentifier("OpenFileController") as! OpenFileViewController
        initialView.url = url
        window?.rootViewController?.presentViewController(initialView, animated: true, completion: { () -> Void in })

        return true
    }
    
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//        println("will resign active")
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        println("did enter background")
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        println("will enter foreground")
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        println("did become active")
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        self.saveContext()
	}
    
//
//    func textFieldBegan(theNotification: NSNotification)
//    {
//        println("APP DELEGATE")
//        let textField = theNotification.object as! UITextField
//        
//        if (inputAccessory == nil)
//        {
//            let width = UIScreen.mainScreen().bounds.width
//            inputAccessory = inputAccessoryView
////            inputAccessory = UIView(frame: CGRectMake(0, 0, width , 265))
//        }
//        textField.inputView = inputAccessory
//        textField.inputAccessoryView = inputAccessory
//        println(textField.inputView)
//        println(textField.inputAccessoryView)
//        inputAccessoryView?.superview?.frame = CGRectMake(0, 759, 768, 265)
//    }

    
}

