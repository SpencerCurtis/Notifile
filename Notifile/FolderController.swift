//
//  FolderController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

class FolderController {
    
    static let fileManager = FileManager()
    
    static var folders: [Folder] {
        
        let moc = CoreDataStack.context
        
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        let fetchResults = try? moc.fetch(request)
        
        return fetchResults ?? []
    }

    @discardableResult static func createFolderWith(url: URL, observationType: ObservationType) -> Folder {
        let folder = Folder(url: url, observationType: observationType, isObserving: true)
        
        saveToPersistentStore()
        
        return folder
    }
    
    static func mockFolders() {
        
        let url = URL(string: "file:///Users/SpencerCurtis/Desktop/")
        createFolderWith(url: url!, observationType: .added)
    }
    
    
    static func getContentsOf(folder: Folder) {
        
    }
    
    static func getDifferencesIn(folder: Folder) -> (addedFiles: [URL], deletedFiles: [URL]) {
        
        guard let previousFiles = folder.files?.array as? [URL] else { return ([], []) }

        let currentFiles = getURLsForAllFilesIn(folder: folder, getURLsRecursively: false)
        
        let addedFiles = checkForAddedFilesIn(previousFiles: previousFiles, currentFiles: currentFiles)
        let deletedFiles = checkForDeletedFilesIn(previousFiles: previousFiles, currentFiles: currentFiles)

        return (addedFiles, deletedFiles)
    }
    
    static func checkForAddedFilesIn(previousFiles: [URL], currentFiles: [URL]) -> [URL] {
        
        var addedFiles: [URL] = []
        
        for currentFile in currentFiles {
            if !previousFiles.contains(currentFile) {
                addedFiles.append(currentFile)
            }
        }
        
        return addedFiles
    }
    
    static func checkForDeletedFilesIn(previousFiles: [URL], currentFiles: [URL]) -> [URL] {

        var deletedFiles: [URL] = []
        
        for previousFile in previousFiles {
            if !currentFiles.contains(previousFile) { deletedFiles.append(previousFile) }
        }
        
        return deletedFiles
    }
    
    
    static func getURLsForAllFilesIn(folder: Folder, getURLsRecursively: Bool) -> [URL] {
        
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
    
    static func saveToPersistentStore() {
        let moc = CoreDataStack.context
        
        do {
            try moc.save()
        } catch {
            NSLog("Error saving items to Managed Object Context.")
        }
    }
    
    
}
