//
//  Scanner.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class Scanner
{
    var timer = NSTimer()
    var timeInterval:Double = 0.0
    var buttonBorderColor = 0	// from settings
    var buttonBorderWidth: CGFloat = 10	// from settings
    var buttonStyle = 0	// from settings
    var scanMode = 0	// from settings
    var buttonSize = 0
    var defaults = NSUserDefaults.standardUserDefaults()
    var secondStageOfSelection = false
//    public class var sharedInstance: Scanner{
//        struct SharedInstance {
//            static let instance = Scanner()
//        }
//        return SharedInstance.instance
//    }


    func selectionMade(playAudio: Bool){}
    
    func update()
    {
        self.timeInterval = defaults.doubleForKey("scanRate")
        self.buttonBorderColor = defaults.integerForKey("buttonBorderColor")
        self.buttonBorderWidth = CGFloat (defaults.integerForKey("buttonBorderWidth"))
    }
    
    func setScanMode() {}
}