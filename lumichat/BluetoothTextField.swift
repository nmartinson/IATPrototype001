//
//  BluetoothTextField.swift
//  Noddle
//
//  Created by Nick Martinson on 4/21/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class BluetoothTextField: UITextField
{
    override func caretRectForPosition(position: UITextPosition!) -> CGRect
    {
        return CGRectZero
    }
}