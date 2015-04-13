//
//  TableViewCellEditView.swift
//  Noddle
//
//  Created by Nick Martinson on 4/13/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewEditDelegate
{
    func tableViewEditViewEditPressed(indexPath: NSIndexPath)
    func tableViewEditViewdeletePressed(indexPath: NSIndexPath)
    func tableViewEditViewcancelPressed()
}

class TableViewCellEditView: UIView
{
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var delegate:TableViewEditDelegate?
    var indexPath:NSIndexPath?
    
    
    init(frame: CGRect, indexPath: NSIndexPath)
    {
        super.init(frame: frame)
        self.indexPath = indexPath
        let editView = NSBundle.mainBundle().loadNibNamed("TableViewCellEditView", owner: self, options: nil).first as! UIView
        editView.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 150, 0, 150, 43)
        self.addSubview(editView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let editView = NSBundle.mainBundle().loadNibNamed("TableViewCellEditView", owner: self, options: nil).first as! UIView
        editView.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 150, 0, 150, 43)
        self.addSubview(editView)
        
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func deleteButtonPressed(sender: UIButton)
    {
        delegate?.tableViewEditViewdeletePressed(indexPath!)
    }

    @IBAction func editButtonPressed(sender: UIButton)
    {
//        println("Edit indexPath: \(indexPath?.row)")
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        delegate?.tableViewEditViewcancelPressed()
    }
    
}