//
//  ObservedFoldersListViewController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class ObservedFoldersListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    private enum CellIdentifiers: String {
        case folderNotificationCheckboxCell = "folderNotificationCheckboxCell"
        case folderNameCell = "folderNameCell"
        case notificationTriggerTypeCell = "notificationTriggerTypeCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let folder = FolderController.folders[row]
        
        switch tableColumn {
            
        case tableView.tableColumns[0]:
            
            guard let cell = tableView.make(withIdentifier: CellIdentifiers.folderNotificationCheckboxCell.rawValue, owner: nil) as? FolderNotificationCheckboxCell else { return nil }
            
            cell.notificationsAreOnButton.state = folder.isObserving == false ? 0 : 1

            return cell
            
        case tableView.tableColumns[1]:
            
            guard let cell = tableView.make(withIdentifier: CellIdentifiers.folderNameCell.rawValue, owner: nil) as? NSTableCellView else { return nil }

            cell.textField?.stringValue = folder.url?.pathComponents.last ?? "No name"
            return cell
            
        case tableView.tableColumns[2]:
            
            
            guard let cell = tableView.make(withIdentifier: CellIdentifiers.notificationTriggerTypeCell.rawValue, owner: nil) as? NotificationTriggerTableViewCellView else { return nil }
            guard let observationTypeString = folder.observationTypeString else { return nil }
            
            cell.popupButton.selectItem(withTitle: observationTypeString)
            
            return cell
        default:
            return nil
        }
    }
}
