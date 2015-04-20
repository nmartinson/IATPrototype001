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
    
    var tableView:UITableView?
    var currentCell = 0
    var previousCell = 0
    var editButtonIndex = 0
    var editButtonIndexPrevious = 0
    var dataSource: NSMutableArray = []
    var timer = NSTimer()
    var editMode = false

    
    func reloadSource(data: NSMutableArray)
    {
        dataSource = data
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func initialization(data: NSMutableArray)
    {
        dataSource = data
        editMode = false
        update()
        if switchmode == SWITCHMODE.SINGLE.rawValue
        {
            setScanMode()
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
    func addCell(cell: TableViewCellEditView)
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
            (dataSource[currentCell] as! UIButton).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as! UIButton).layer.borderWidth = 2
        }
        else if currentCell == 1
        {
            (dataSource[currentCell] as! UIButton).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as! UIButton).layer.borderWidth = 2
        }
        else if currentCell == 2
        {
            (dataSource[currentCell] as! UITextField).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[currentCell] as! UITextField).layer.borderWidth = 2
        }
        else
        {
            (dataSource[currentCell] as! TableViewCellEditView).highlighted = true
            (dataSource[currentCell] as! TableViewCellEditView).selected = true
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
        for(var i = 0; i < 3; i++)
        {
            (dataSource[i]).layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[i]).layer.borderWidth = 0
        }
        for(var i = 3; i < dataSource.count; i++)
        {
            (dataSource[i] as! TableViewCellEditView).highlighted = false
            (dataSource[i] as! TableViewCellEditView).selected = false
        }
        
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func removeAllItemsFromDataSource()
    {
        let range = NSRange(location: 3, length: dataSource.count - 1)
        dataSource.removeObjectsInRange(range)
    }
    
    
    func editScan(cellIndex: Int)
    {
        (dataSource[cellIndex] as! TableViewCellEditView).highlighted = false
        (dataSource[cellIndex] as! TableViewCellEditView).selected = false
        (dataSource[cellIndex] as! TableViewCellEditView).cancelButton.layer.borderWidth = 0
        (dataSource[cellIndex] as! TableViewCellEditView).deleteButton.layer.borderWidth = 0
        
        if editButtonIndex == 0
        {
            (dataSource[cellIndex] as! TableViewCellEditView).cancelButton.layer.borderColor = UIColor.blackColor().CGColor
           (dataSource[cellIndex] as! TableViewCellEditView).cancelButton.layer.borderWidth = 5
        }
        else if editButtonIndex == 1
        {
            (dataSource[cellIndex] as! TableViewCellEditView).deleteButton.layer.borderColor = UIColor.blackColor().CGColor
            (dataSource[cellIndex] as! TableViewCellEditView).deleteButton.layer.borderWidth = 5

        }
        
        editButtonIndexPrevious = editButtonIndex
        if editButtonIndex < 1
        {
            editButtonIndex++
        }
        else
        {
            editButtonIndex = 0
        }
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
                if previousCell == 0 || previousCell == 1
                {
                    selectedObject = dataSource[previousCell] as! UIButton
                    selectedObject?.sendActionsForControlEvents(.TouchUpInside)
                }
                else if previousCell == 2
                {
                    selectedObject = dataSource[2] as! UITextField
                    selectedObject?.becomeFirstResponder()
                }
                else
                {
                    selectedObject = dataSource[previousCell] as! TableViewCellEditView
                    Util().speak( (selectedObject as! TableViewCellEditView).textLabel!.text! )
                    setScanMode() // restart time
                }
                secondStageOfSelection = !secondStageOfSelection
                return ""
            case SWITCHMODE.DOUBLE.rawValue:
                if(previousCell == 0 || previousCell == 1) // navBar button
                {
                    if inputKey! == "enter" // secondStageOfSelection
                    {
                        selectedObject = dataSource[previousCell] as! UIButton
                        selectedObject?.sendActionsForControlEvents(.TouchUpInside)
                    }
                    else if inputKey! == "space"
                    {
                        serialScan()
                    }
                }
                else // if serial scan, make selection
                {
                    if inputKey! == "enter"
                    {
                        if previousCell == 2
                        {
                            selectedObject = dataSource[2] as! UITextField
                            selectedObject?.becomeFirstResponder()
                        }
                        else
                        {
                            selectedObject = dataSource[previousCell] as! TableViewCellEditView

                            if editMode == true
                            {
                                if secondStageOfSelection
                                {
                                    if editButtonIndexPrevious == 0
                                    {
                                        (selectedObject as! TableViewCellEditView).cancelButton.sendActionsForControlEvents(.TouchUpInside)
                                        (dataSource[previousCell] as! TableViewCellEditView).cancelButton.layer.borderWidth = 0

                                    }
                                    else if editButtonIndexPrevious == 1
                                    {
                                        (selectedObject as! TableViewCellEditView).deleteButton.sendActionsForControlEvents(.TouchUpInside)
//                                        (dataSource[previousCell] as! TableViewCellEditView).deleteButton.layer.borderWidth = 0
//                                        dataSource.removeObjectAtIndex(previousCell)
                                    }
                                }
                                else
                                {
                                    editButtonIndex = 0
                                    editScan(previousCell)
                                }
                                secondStageOfSelection = !secondStageOfSelection
                            }
                            else
                            {
                                Util().speak( (selectedObject as! TableViewCellEditView).phraseLabel!.text! )
                            }
                        }
                    }
                    else
                    {
                        if editMode == true && previousCell > 2 && secondStageOfSelection
                        {
                            editScan(previousCell)
                        }
                        else
                        {
                            serialScan()
                        }
                    }
                }

            default:
                println("error")
        }
        
        return ""
    }
    
}