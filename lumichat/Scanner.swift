//
//  Scanner.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

enum SWITCHMODE: Int{
    case SINGLE = 0
    case DOUBLE = 1
}

class Scanner
{
    var navBarButtons:[UIButton] = [] // stores buttonsfor nav bar
    var timeInterval:Double = 0.0
    var buttonBorderColor = 0	// from settings
    var buttonBorderWidth: CGFloat = 10	// from settings
    var buttonStyle = 0	// from settings
    var scanMode = 0	// from settings
    var buttonSize = 0
    var defaults = NSUserDefaults.standardUserDefaults()
    var secondStageOfSelection = false
    var switchmode = 1
    var scanModeString = "serialScan"
    


    func selectionMade(playAudio: Bool,inputKey: String?) -> String {return ""}
    
    func setupNavBar(navButtons: [UIButton])
    {
        self.navBarButtons = navButtons
    }
    
    func update()
    {
        self.switchmode = NSUserDefaults.standardUserDefaults().integerForKey("numberOfSwitches")
        self.timeInterval = defaults.doubleForKey("scanRate")
        self.buttonBorderColor = defaults.integerForKey("buttonBorderColor")
        self.buttonBorderWidth = CGFloat (defaults.integerForKey("buttonBorderWidth"))
        if switchmode == SWITCHMODE.SINGLE.rawValue
        {
            setScanMode()
        }
    }
    
    func setScanMode() {}
    
}