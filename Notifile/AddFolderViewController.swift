//
//  AddFolderViewController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class AddFolderViewController: NSViewController {

    @IBOutlet weak var selectedFolderPathControl: NSPathControl!
    @IBOutlet weak var observationTypePopupButton: NSPopUpButton!
    
    weak var delegate: AddFolderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func selectFolderButtonClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard let path = openPanel.url, result == NSFileHandlingPanelOKButton else { return }
            
            self.selectedFolderPathControl.url = path
            
            // TODO: Implement this when you handle dark menu bars.
            
            //            if self.appearance == "Dark" {
            //                self.outputPathControl.pathComponentCells().forEach({$0.textColor = NSColor.white})
            //            }
        }
    }
    
    @IBAction func observationTypePopupButtonValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let selectedFolderPath = self.selectedFolderPathControl.url, let selectedItem = observationTypePopupButton.selectedItem, let observationType = ObservationType(rawValue: selectedItem.title) else { return }
        
        let folder = FolderController.createFolderWith(url: selectedFolderPath, observationType: observationType)
        delegate?.folderWasCreated(folder: folder)
        
        dismissSheet()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismissSheet()
    }
    
    override func cancelOperation(_ sender: Any?) {
        dismissSheet()
    }
    
    func dismissSheet() {
        self.view.window?.sheetParent?.endSheet(self.view.window!)
    }
}

protocol AddFolderDelegate: class {
    func folderWasCreated(folder: Folder?)
}
