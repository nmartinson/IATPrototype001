//
//  KeyboardScanner.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation

class KeyboardScanner: Scanner
{
    public class var sharedInstance: KeyboardScanner{
        struct SharedInstance {
            static let instance = KeyboardScanner()
        }
        return SharedInstance.instance
    }
    
    private var row1:NSMutableArray = []
    private var row2:NSMutableArray = []
    private var row3:NSMutableArray = []
    private var row4:NSMutableArray = []
    private var scanningMode = "rowScan"
    private var currentRow = 0
    private var currentButton = 0
    private var previousButton = 0
    private var previousRow = 0
    var timer = NSTimer()

    
    /********************************************************************************************************
    *   Configures the arrays of button rows
    ********************************************************************************************************/
    func initialization(keyboard: [UIButton])
    {
        row1.removeAllObjects()
        row2.removeAllObjects()
        row3.removeAllObjects()
        row4.removeAllObjects()
        timer.invalidate()
        update()
        for(var i = 0; i < 10; i++)
        {
            row1.addObject(keyboard[i] as UIButton)
        }
        var j = 0
        for(var i = 10; i < 19; i++)
        {
            row2.addObject(keyboard[i] as UIButton)
        }
        j = 0
        for(var i = 19; i < 27; i++)
        {
            row3.addObject(keyboard[i] as UIButton)
        }
        row4.addObject(keyboard[27] as UIButton) // space button
        row4.addObject(keyboard[28] as UIButton) // delete button
        row4.addObject(keyboard[29] as UIButton) // save button
        setScanMode()
    }
    
    /********************************************************************************************************
    *
    ********************************************************************************************************/
    override func setScanMode()
    {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector(scanningMode), userInfo: nil, repeats: true)
    }
    
    /********************************************************************************************************
    *   Scan one row at a time
    ********************************************************************************************************/
    @objc func rowScan()
    {
        clearAllButtonSelections()
        
        let row = getKeyRow()
        previousRow = currentRow

        for(var i = 0; i < row.count; i++)
        {
            (row[i] as! UIButton).highlighted = true
            (row[i] as! UIButton).layer.borderColor = Constants.getColor(buttonBorderColor)
            (row[i] as! UIButton).layer.borderWidth = 3
        }
        
        if currentRow < 3
        {
            currentRow++
        }
        else
        {
            currentRow = 0
        }
    }
    
    
    /********************************************************************************************************
    *   Scan one column at a time
    ********************************************************************************************************/
    @objc func columnScan()
    {
        clearAllButtonSelections()
        let row = getKeyRow()
        previousButton = currentButton
        (row[currentButton] as! UIButton).highlighted = true
        (row[currentButton] as! UIButton).layer.borderColor = Constants.getColor(buttonBorderColor)
        (row[currentButton] as! UIButton).layer.borderWidth = 3

        if currentButton < row.count - 1
        {
            currentButton++
        }
        else
        {
            currentButton = 0
        }
    }
    
    /********************************************************************************************************
    *   Deselects all the buttons
    ********************************************************************************************************/
    func clearAllButtonSelections()
    {
        // Clear the selection properties from all buttons
        for(var i = 0; i < row1.count; i++)
        {
            (row1[i] as! UIButton).selected = false
            (row1[i] as! UIButton).layer.borderWidth = 0
            (row1[i] as! UIButton).highlighted = false
        }
        for(var i = 0; i < row2.count; i++)
        {
            (row2[i] as! UIButton).selected = false
            (row2[i] as! UIButton).layer.borderWidth = 0
            (row2[i] as! UIButton).highlighted = false
        }
        for(var i = 0; i < row3.count; i++)
        {
            (row3[i] as! UIButton).selected = false
            (row3[i] as! UIButton).layer.borderWidth = 0
            (row3[i] as! UIButton).highlighted = false
        }
        for(var i = 0; i < row4.count; i++)
        {
            (row4[i] as! UIButton).selected = false
            (row4[i] as! UIButton).layer.borderWidth = 0
            (row4[i] as! UIButton).highlighted = false
        }
    }

    /********************************************************************************************************
    *   Get reference to desired row
    ********************************************************************************************************/
    func getKeyRow() -> NSMutableArray
    {
        var row:NSMutableArray?
        switch(currentRow)
        {
        case 0:
            row = row1
        case 1:
            row = row2
        case 2:
            row = row3
        case 3:
            row = row4
        default:
            println("error")
        }
        return row!
    }

    
    /* ***********************************************************************************************************
    *	Gets called when the user taps the screen. If using srial scan, it calls for the button to pressed, which
    *   plays the audio. If a different scan mode, it checks if it was the first tap or second tap. First tap changes
    *   scan mode, second selection, makes the selection.
    *********************************************************************************************************** */
    override func selectionMade(playAudio: Bool, inputKey: String?) -> String
    {
        timer.invalidate()
        if( secondStageOfSelection)
        {
            let row = getKeyRow()
            let button = row[previousButton] as! UIButton // get pressed button
            button.sendActionsForControlEvents(UIControlEvents.TouchUpInside) // tell the button it was pressed
        }
        secondStageOfSelection = !secondStageOfSelection
        
        switch scanningMode
        {
            case "rowScan":
                scanningMode = "columnScan"
                currentRow = previousRow
            case "columnScan":
                scanningMode = "rowScan"
            default:
                println("Error")
        }
        setScanMode()   // this resets the timer to start scanning again
        currentButton = 0 // restart at 1st button in row
        return ""
    }
    

    
    
    

}