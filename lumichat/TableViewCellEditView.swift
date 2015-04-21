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
    @IBOutlet weak var phraseTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var delegate:TableViewEditDelegate?
    var indexPath:NSIndexPath?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib()
    {
        doneEditing()
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
        self.deleteButton.layer.borderWidth = 0
        self.cancelButton.layer.borderWidth = 0
        phraseTrailingConstraint.constant = 140
    }
    
    func doneEditing()
    {
        deleteButton.hidden = true
        cancelButton.hidden = true
        phraseTrailingConstraint.constant = -8
    }
    
}