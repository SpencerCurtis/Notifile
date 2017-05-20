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
    var fileSource: DispatchSourceFileSystemObject?
    var isObserving = false
    var folder: Folder
    
    weak var delegate: FolderObserverDelegate?
    
    var eventTypes: DispatchSource.FileSystemEvent
    
    init(folder: Folder, eventTypes: DispatchSource.FileSystemEvent) {
        self.folder = folder
        self.eventTypes = eventTypes
    }
 
    deinit {
        stopObservingChanges()
        print("Deinitializing FolderObserver")
    }
    
    func beginObservingChanges() {
        
        guard let url = folder.url, !isObserving else { return }
        
        isObserving = true
        
        fileDescriptor = open(url.path, O_EVTONLY)
    
        let queue = DispatchQueue(label: "com.SpencerCurtis.Notifile.\(url.absoluteString)")
        self.fileSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: self.eventTypes, queue: queue)
        
        self.fileSource?.setEventHandler(handler: { 
            self.delegate?.changesWereObservedFor(folderObserver: self)
        })
        
        self.fileSource?.resume()
        
    }
    
    func stopObservingChanges() {
        
        guard isObserving else { return }
        
        self.fileSource?.cancel()
        close(self.fileDescriptor)
        isObserving = false
    }
}

protocol FolderObserverDelegate: class {
    func changesWereObservedFor(folderObserver: FolderObserver)
}
