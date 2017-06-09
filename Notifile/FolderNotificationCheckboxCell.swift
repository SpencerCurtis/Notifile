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
    
    var folder: Folder? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let folder = folder else { return }
        self.notificationsAreOnButton.state = folder.shouldBeObserved == false ? 0 : 1
    }
    
    @IBAction func notificationsAreOnButtonClicked(_ sender: Any) {
        delegate?.toggleNotificationObservation(sender: self)
    }
    
    func appearanceForDarkMenu() {
        
    }
    
    
}

protocol FolderNotificationCheckboxCellDelegate: class {
    func toggleNotificationObservation(sender: FolderNotificationCheckboxCell)
}
