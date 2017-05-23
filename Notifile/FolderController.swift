//
//  FolderController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

typealias ModifiedFiles = (addedFiles: [URL], deletedFiles: [URL])

class FolderController: FolderObserverDelegate {
    
    static let shared = FolderController()
    
    
    let fileManager = FileManager()
    
    let moc = CoreDataStack.context
    
    var foldersHaveBeenFetchedBefore = false
    
    var folders: [Folder] {
        
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        let fetchResults = try? moc.fetch(request)
        
        if !foldersHaveBeenFetchedBefore { fetchResults?.forEach({$0.isBeingObserved = false}) }
        foldersHaveBeenFetchedBefore = true
        
        fetchResults?.forEach({ setupFolderObserverFor(folder: $0) })
        
        return fetchResults ?? []
    }
    
    var folderObservers: [FolderObserver] = []
    
    @discardableResult func createFolderWith(url: URL, observationType: ObservationType) -> Folder {
        let folder = Folder(url: url, observationType: observationType)
        
        saveToPersistentStore()
        
        setupFolderObserverFor(folder: folder)
        
        return folder
    }
    
    @discardableResult func createFileWith(url: URL, folder: Folder) -> File {
        let file = File(url: url, folder: folder)
        saveToPersistentStore()
        return file
    }
    
    func delete(file: File) {
        moc.delete(file)
        saveToPersistentStore()
    }
    
    func changesWereObservedFor(folderObserver: FolderObserver) {
        
        let modifiedFiles = getDifferencesIn(folder: folderObserver.folder)
       print("Changed observed")
        FileNotificationController.sendFileNotificationWith(folder: folderObserver.folder, modifiedFiles: modifiedFiles)
    }
    
    
    func getDifferencesIn(folder: Folder) -> ModifiedFiles {
        
        guard let previousFiles = folder.files?.array as? [File] else { return ([], []) }
        
        let previousFileURLs = previousFiles.flatMap({$0.url})
        let currentFiles = getURLsForAllFilesIn(folder: folder, getURLsRecursively: false)
        
        let addedFiles = checkForAddedFilesIn(previousFiles: previousFileURLs, currentFiles: currentFiles)
        let deletedFiles = checkForDeletedFilesIn(previousFiles: previousFileURLs, currentFiles: currentFiles)
        
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
    
    func removeObserversForAllFolders() {
        self.folders.forEach({$0.hasObserver = false})
        saveToPersistentStore()
    }
    
    func setupFolderObserverFor(folder: Folder) {
        
        guard folderObservers.filter({$0.folder == folder}).count == 0 else { return }
        
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
        
        let fileURLs = getURLsForAllFilesIn(folder: folder, getURLsRecursively: false)
        
        guard let preexistingFileURLS = folder.files?.flatMap({($0 as! File).urlString}) else { return }
        
        let newFileURLs = fileURLs.filter({!preexistingFileURLS.contains($0.absoluteString)})
        
        newFileURLs.forEach({createFileWith(url: $0, folder: folder)})
        
        let folderObserver = FolderObserver(folder: folder, eventTypes: eventTypes)
        
        folderObserver.delegate = self
        
        self.folderObservers.append(folderObserver)
        
        folder.hasObserver = true
        
        toggleObservationFor(folder: folder)
        
    }
    
    func toggleObservationFor(folder: Folder) {
        
        guard let folderObserver = folderObservers.filter({$0.folder == folder}).first else { return }
        
        if folder.isBeingObserved == true {
            folderObserver.stopObservingChanges()
        } else {
            folderObserver.beginObservingChanges()
        }
        
    }
    
    func toggleIsObservingFor(folder: Folder, isBeingObserved: Bool) {
        folder.isBeingObserved = isBeingObserved
        saveToPersistentStore()
    }
    
    func update(folder: Folder, with modifiedFiles: ModifiedFiles) {
        
        guard let folderFiles = folder.files?.array as? [File] else { return }

        for file in modifiedFiles.addedFiles {
            FolderController.shared.createFileWith(url: file, folder: folder)
        }
        
        for deletedFileURL in modifiedFiles.deletedFiles {
            
            guard let file = folderFiles.filter({$0.urlString == deletedFileURL.absoluteString}).first else { return }
            
            FolderController.shared.delete(file: file)
        }

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
    
    // MARK: Persistence - Core Data
    
    func remove(folder: Folder) {
        moc.delete(folder)
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        
        do {
            try moc.save()
        } catch {
            NSLog("Error saving items to Managed Object Context.")
        }
    }
    
    
}
