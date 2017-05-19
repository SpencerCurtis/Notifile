//
//  FolderObserver.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/17/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation

class FolderObserver {
    
    var fileDescriptor: CInt = -1
    var url: URL
    var fileSource: DispatchSourceFileSystemObject?
    var isObserving = false
    
    weak var delegate: FolderObserverDelegate?
    
    var eventTypes: DispatchSource.FileSystemEvent
    
    init(url: URL, eventTypes: DispatchSource.FileSystemEvent) {
        self.url = url
        self.eventTypes = eventTypes
    }
 
    deinit {
        stopMonitoringChanges()
        print("Deinitializing FolderObserver")
    }
    
    func observeChanges() {
        
        guard !isObserving else { return }
        
        isObserving = true
        
        fileDescriptor = open(url.path, O_EVTONLY)
    
        let queue = DispatchQueue(label: "com.SpencerCurtis.Notifile.\(url.absoluteString)")
        self.fileSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: self.eventTypes, queue: queue)
        
        self.fileSource?.setEventHandler(handler: { 
            self.delegate?.changesWereObservedFor(folderObserver: self)
        })
        
        self.fileSource?.resume()
        
    }
    
    func stopMonitoringChanges() {
        self.fileSource?.cancel()
        close(self.fileDescriptor)
        isObserving = false
    }
}

protocol FolderObserverDelegate: class {
    func changesWereObservedFor(folderObserver: FolderObserver)
}
