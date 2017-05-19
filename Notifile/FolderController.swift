//
//  FolderController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

class FolderController: FolderObserverDelegate {
    
    static let shared = FolderController()
    
    let fileManager = FileManager()
    
    let moc = CoreDataStack.context
    
    var folders: [Folder] {
        
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        let fetchResults = try? moc.fetch(request)
        
        return fetchResults ?? []
    }
    
    var folderObservers: [FolderObserver] = []
    
    @discardableResult  func createFolderWith(url: URL, observationType: ObservationType) -> Folder {
        let folder = Folder(url: url, observationType: observationType)
        
        saveToPersistentStore()
        
        return folder
    }
    
    func changesWereObservedFor(folderObserver: FolderObserver) {
        
    }
    
    
    func getDifferencesIn(folder: Folder) -> (addedFiles: [URL], deletedFiles: [URL]) {
        
        guard let previousFiles = folder.files?.array as? [URL] else { return ([], []) }
        
        let currentFiles = getURLsForAllFilesIn(folder: folder, getURLsRecursively: false)
        
        let addedFiles = checkForAddedFilesIn(previousFiles: previousFiles, currentFiles: currentFiles)
        let deletedFiles = checkForDeletedFilesIn(previousFiles: previousFiles, currentFiles: currentFiles)
        
        return (addedFiles, deletedFiles)
    }
    
    func checkForAddedFilesIn(previousFiles: [URL], currentFiles: [URL]) -> [URL] {
        
        var addedFiles: [URL] = []
        
        for currentFile in currentFiles {
            if !previousFiles.contains(currentFile) {
                addedFiles.append(currentFile)
            }
        }
        
        return addedFiles
    }
    
    func setupFolderObserverFor(folder: Folder) {
        
        guard let folderURL = folder.url, !folder.hasObserver else { return }
        
        var eventTypes: DispatchSource.FileSystemEvent = []
        
        switch folder.observationType {
        case .added:
            eventTypes = [.write]
        case .deleted:
            eventTypes = [.delete]
        case .both:
            eventTypes = [.write, .delete]
        default:
            break
        }
        
        let folderObserver = FolderObserver(url: folderURL, eventTypes: eventTypes)
        
        folderObserver.delegate = self
        
        self.folderObservers.append(folderObserver)
        
        folder.hasObserver = true
        
    }
    
    
    func checkForDeletedFilesIn(previousFiles: [URL], currentFiles: [URL]) -> [URL] {
        
        var deletedFiles: [URL] = []
        
        for previousFile in previousFiles {
            if !currentFiles.contains(previousFile) { deletedFiles.append(previousFile) }
        }
        
        return deletedFiles
    }
    
    func getURLsForAllFilesIn(folder: Folder, getURLsRecursively: Bool) -> [URL] {
        
        guard let folderURLString = folder.urlString, let folderURL = URL(string: folderURLString), folderURL.hasDirectoryPath else { return [] }
        
        
        guard let contents = try? self.fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return [] }
        
        var folderContents = contents
        
        var foldersToBeChecked: [URL] = []
        
        guard getURLsRecursively else { return folderContents }
        
        for item in folderContents {
            
            guard item.hasDirectoryPath else { folderContents.append(item); break }
            
            foldersToBeChecked.append(item)
            folderContents += getURLsForAllFilesIn(folder: folder,  getURLsRecursively: true)
            
        }
        
        if foldersToBeChecked.contains(folderURL) {
            guard let index = foldersToBeChecked.index(of: folderURL) else { return folderContents }
            foldersToBeChecked.remove(at: index)
        }
        
        
        return folderContents
    }
    
    func remove(folder: Folder) {
        moc.delete(folder)
    }
    
    func saveToPersistentStore() {
        
        do {
            try moc.save()
        } catch {
            NSLog("Error saving items to Managed Object Context.")
        }
    }
    
    
}
