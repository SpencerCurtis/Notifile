//
//  FolderNotificationCheckboxCell.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class FolderNotificationCheckboxCell: NSTableCellView {

    @IBOutlet weak var notificationsAreOnButton: NSButton!
    
    weak var delegate: FolderNotificationCheckboxCellDelegate?
    
    @IBAction func notificationsAreOnButtonClicked(_ sender: Any) {
        delegate?.toggleNotificationObservation(sender: self)
    }
    
    func appearanceForDarkMenu() {
        
    }
    
    
}

protocol FolderNotificationCheckboxCellDelegate: class {
    func toggleNotificationObservation(sender: FolderNotificationCheckboxCell)
}
