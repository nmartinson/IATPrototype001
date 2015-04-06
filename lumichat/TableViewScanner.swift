//
//  TableViewScanner.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation


class TableViewScanner: Scanner
{
    public class var sharedInstance: TableViewScanner{
        struct SharedInstance {
            static let instance = TableViewScanner()
        }
        return SharedInstance.instance
    }
    
    var currentCell = 0
    var previousCell = 0
    var dataSource: NSMutableArray = []
    var timer = NSTimer()

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func initialization(data: NSMutableArray)
    {
        switchmode = NSUserDefaults.standardUserDefaults().integerForKey("numberOfSwitches")
        dataSource = data
        update()
        if switchmode == SWITCHMODE.SINGLE.rawValue
        {
            setScanMode()
        }
        else
        {
            
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func setScanMode()
    {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("serialScan"), userInfo: nil, repeats: true)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func addCell(cell: UITableViewCell)
    {
        dataSource.addObject(cell)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @objc func serialScan()
    {
        clearAllCells()
        
        if currentCell == 0
        {
            (dataSource[currentCell] as UIButton).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as UIButton).layer.borderWidth = 2
        }
        else if currentCell == 1
        {
            (dataSource[currentCell] as UITextField).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as UITextField).layer.borderWidth = 2
        }
        else
        {
            (dataSource[currentCell] as UITableViewCell).highlighted = true
            (dataSource[currentCell] as UITableViewCell).selected = true
        }
        
        previousCell = currentCell
        
        if currentCell < dataSource.count - 1
        {
            currentCell++
        }
        else
        {
            currentCell = 0
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func clearAllCells()
    {
        for(var i = 0; i < 2; i++)
        {
            (dataSource[i]).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[i]).layer.borderWidth = 0
        }
        for(var i = 2; i < dataSource.count; i++)
        {
            (dataSource[i] as UITableViewCell).highlighted = false
            (dataSource[i] as UITableViewCell).selected = false
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func removeAllItemsFromDataSource()
    {
        println(dataSource.count)
        let range = NSRange(location: 2, length: dataSource.count - 1)
        dataSource.removeObjectsInRange(range)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func selectionMade(playAudio: Bool, inputKey: String?) -> String
    {
        var selectedObject:AnyObject?

        switch(switchmode)
        {
            case SWITCHMODE.SINGLE.rawValue:
                timer.invalidate()
                if previousCell == 0
                {
                    selectedObject = dataSource[0] as UIButton
                    selectedObject?.sendActionsForControlEvents(.TouchUpInside)
                }
                else if previousCell == 1
                {
                    selectedObject = dataSource[1] as UITextField
                    selectedObject?.becomeFirstResponder()
                }
                else
                {
                    selectedObject = dataSource[previousCell] as UITableViewCell
                    Util().speak( (selectedObject as UITableViewCell).textLabel!.text! )
                    setScanMode() // restart time
                }
                secondStageOfSelection = !secondStageOfSelection
                return ""
            case SWITCHMODE.DOUBLE.rawValue:
                if(previousCell == 0) // navBar button
                {
                    if inputKey! == "enter" // secondStageOfSelection
                    {
                        selectedObject = dataSource[0] as UIButton
                        selectedObject?.sendActionsForControlEvents(.TouchUpInside)
                    }
                    else if inputKey! == "space"
                    {
                        serialScan()
                    }
                }
                else // if serial scan, make selection
                {
                    println("second stage \(inputKey)")
                    if inputKey! == "enter"
                    {
                        if previousCell == 1
                        {
                            selectedObject = dataSource[1] as UITextField
                            selectedObject?.becomeFirstResponder()
                        }
                        else
                        {
                            selectedObject = dataSource[previousCell] as UITableViewCell
                            Util().speak( (selectedObject as UITableViewCell).textLabel!.text! )
                        }
                    }
                    else
                    {
                        serialScan()
                    }
                }

            default:
                println("error")
        }
        
        return ""
    }
    
}