//
//  ObservedFoldersListViewController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa


class ObservedFoldersListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSPopoverDelegate, AddFolderDelegate, FolderNotificationCheckboxCellDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var appearance: String {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
    }
    
    private enum CellIdentifiers: String {
        case folderNotificationCheckboxCell = "folderNotificationCheckboxCell"
        case folderNameCell = "folderNameCell"
        case notificationTriggerTypeCell = "notificationTriggerTypeCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCell(notification:)), name: FolderController.shared.foldersHaveObserversNotification, object: nil)
    }
    
    @IBAction func addFolderButtonClicked(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let addFolderWC = storyboard.instantiateController(withIdentifier: "AddFolderWindowController") as? NSWindowController, let window = addFolderWC.window, let addFolderVC = addFolderWC.contentViewController as? AddFolderViewController else { return }
        
        addFolderVC.delegate = self
        
        self.view.window?.beginSheet(window, completionHandler: nil)
    }
    
    @IBAction func removeFolderButtonClicked(_ sender: Any) {
        guard tableView.selectedRow != -1 else { return }
        
        let folder = FolderController.shared.folders[tableView.selectedRow]
        
        FolderController.shared.remove(folder: folder)
        
        self.tableView.reloadData()
    }
    
    func refreshCell(notification: Notification) {
        
        guard let folder = notification.userInfo?["folder"] as? Folder else { return }
        
        self.tableView.reloadData()
    }
    

    func folderWasCreated(folder: Folder?) {
        self.tableView.reloadData()
    }

    func toggleNotificationObservation(sender: FolderNotificationCheckboxCell) {
        
        let row = tableView.row(for: sender)
        
        guard row != -1 else { return }
        
        let folder = FolderController.shared.folders[row]
        
        let shouldBeObserved = sender.notificationsAreOnButton.state == 0 ? false : true
        FolderController.shared.toggleShouldBeObservedFor(folder: folder, shouldBeObserved: shouldBeObserved)
        FolderController.shared.toggleObservationFor(folder: folder)
        
    }
    
    func changeAppearanceForMenuStyle() {
        if appearance == "Dark" {

        } else {
            
        }
    }
    
    // MARK: - NSPopoverDelegate
    
    func popoverWillShow(_ notification: Notification) {
        tableView.reloadData()
        changeAppearanceForMenuStyle()
    }
    
    // MARK: - NSTableViewDataSource/Delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return FolderController.shared.folders.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let folder = FolderController.shared.folders[row]
        
        switch tableColumn {
            
        case tableView.tableColumns[0]:
            
            guard let cell = tableView.make(withIdentifier: CellIdentifiers.folderNotificationCheckboxCell.rawValue, owner: nil) as? FolderNotificationCheckboxCell else { return nil }
            
            cell.folder = folder
            cell.delegate = self
            
            if appearance == "Dark" { cell.appearanceForDarkMenu() }
            
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
