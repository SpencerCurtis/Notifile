//
//  AppDelegate.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/17/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    let popover = NSPopover()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        guard let button = statusItem.button else { return }
        button.image = NSImage(named: "StatusBarButtonImage")
        button.action = #selector(togglePopover)

        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let observedFoldersListViewController = storyboard.instantiateController(withIdentifier: "ObservedFoldersListViewController") as? ObservedFoldersListViewController else { return }
        
        popover.behavior = .semitransient
        popover.contentViewController = observedFoldersListViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePopover(sender:)), name: closePopoverNotification, object: nil)
        togglePopover(sender: self)

        
        
    }
    
    func togglePopover(sender: Any?) {
        popover.isShown == true ? closePopover(sender: sender) : showPopover(sender: sender)
    }
    
    func showPopover(sender: Any?) {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }


    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

}

let closePopoverNotification = Notification.Name("closePopover")
