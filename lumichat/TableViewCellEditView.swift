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
    func tableViewEditViewdeletePressed(indexPath: NSIndexPath)
    func tableViewEditViewcancelPressed()
}

class TableViewCellEditView: UITableViewCell
{
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var delegate:TableViewEditDelegate?
    var indexPath:NSIndexPath?
    
    
//    init(frame: CGRect, indexPath: NSIndexPath)
//    {
//        super.init(frame: frame)
//        self.indexPath = indexPath
//        let editView = NSBundle.mainBundle().loadNibNamed("TableViewCellEditView", owner: self, options: nil).first as! UIView
//        editView.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 140, 0, 140, 43)
//        self.addSubview(editView)
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        let editView = NSBundle.mainBundle().loadNibNamed("TableViewCellEditView", owner: self, options: nil).first as! UIView
//        editView.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 140, 0, 140, 43)
//        self.addSubview(editView)
//        
//    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func deleteButtonPressed(sender: UIButton)
    {
        delegate?.tableViewEditViewdeletePressed(indexPath!)
    }

    @IBAction func cancelButtonPressed(sender: UIButton)
    {
        delegate?.tableViewEditViewcancelPressed()
    }
    
    func setEditing()
    {
        deleteButton.hidden = false
        cancelButton.hidden = false
    }
    
    func doneEditing()
    {
        deleteButton.hidden = true
        cancelButton.hidden = true
    }
    
}