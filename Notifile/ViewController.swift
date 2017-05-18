//
//  ViewController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/17/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var pathLabel: NSTextField!
    @IBOutlet weak var changeObservedLabel: NSTextField!
    
    var observer: FolderObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

    }
    
    @IBAction func openButtonTapped(_ sender: Any) {
        
        let openPanel = NSOpenPanel()
        
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        openPanel.begin { (result) in
            
            guard let path = openPanel.url, result == NSFileHandlingPanelOKButton else { return }
            
            self.observer = FolderObserver(url: path)
            
            self.pathLabel.stringValue = path.absoluteString
            
            self.observer?.observeChanges()
            
            
        }

        
        
    }
   
}

