//
//  test.swift
//  lumichat
//
//  Created by Nick Martinson on 2/11/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardDelegate
{
    func keyWasPressed(key: String)
    func deleteWasPressed()
    func spaceWasPressed()
    func saveWasPressed()
}

class Keyboard:UIView
{
    @IBOutlet var keyCollection: [UIButton]!
    var delegate:KeyboardDelegate?
    
    @IBAction func buttonPressed(sender: UIButton)
    {
        var key = sender.titleLabel!.text!
        if key == "."
        {
            key = key + " "
        }
        delegate?.keyWasPressed(key)
    }
    
    @IBAction func spacePressed(sender: AnyObject)
    {
        delegate?.spaceWasPressed()
    }
    
    @IBAction func deletePressed(sender: AnyObject)
    {
        delegate?.deleteWasPressed()
    }
    
    @IBAction func saveWasPressed(sender: AnyObject)
    {
        delegate?.saveWasPressed()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init()
    {
        super.init()
        let keyboardView = NSBundle.mainBundle().loadNibNamed("Keyboard", owner: self, options: nil).first as UIView


        let height = UIScreen.mainScreen().applicationFrame.height
        let width = UIScreen.mainScreen().applicationFrame.width
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let keyboardHeight = height/3
        let size = CGRectMake(0, height-keyboardHeight+statusHeight, width, keyboardHeight)
        for( var i = 0; i < keyCollection.count; i++)
        {
            keyCollection[i].layer.cornerRadius = 5
            keyCollection[i].userInteractionEnabled = true
        }
        super.frame = size
        keyboardView.frame = CGRectMake(0, 0, frame.width, frame.height)
        self.addSubview(keyboardView)
    }
    
}