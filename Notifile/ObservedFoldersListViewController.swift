//
//  ObservedFoldersListViewController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class ObservedFoldersListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, AddFolderDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private enum CellIdentifiers: String {
        case folderNotificationCheckboxCell = "folderNotificationCheckboxCell"
        case folderNameCell = "folderNameCell"
        case notificationTriggerTypeCell = "notificationTriggerTypeCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        FolderController.mockFolders()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    @IBAction func addFolderButtonClicked(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let addFolderWC = storyboard.instantiateController(withIdentifier: "AddFolderWindowController") as? NSWindowController, let window = addFolderWC.window, let addFolderVC = addFolderWC.contentViewController as? AddFolderViewController else { return }
        
        addFolderVC.delegate = self
        
        self.view.window?.beginSheet(window, completionHandler: nil)
    }
    
    @IBAction func removeFolderButtonClicked(_ sender: Any) {
        guard tableView.selectedRow != -1 else { return }
        
        let folder = FolderController.folders[tableView.selectedRow]
        
        FolderController.remove(folder: folder)
        
        self.tableView.reloadData()
    }
    
    func folderWasCreated(folder: Folder?) {
        self.tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return FolderController.folders.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 28
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
