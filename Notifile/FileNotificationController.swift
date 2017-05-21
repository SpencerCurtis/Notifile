//
//  FileNotificationController.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/20/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CloudKit

class FileNotificationController {
    
    static func sendFileNotificationWith(folder: Folder, modifiedFiles: ModifiedFiles) {
        
        var notificationTitle = ""
        var notificationBody = ""
        
        let folderName = folder.url?.lastPathComponent ?? "No folder name"
        
        let addedFileNames = modifiedFiles.addedFiles.flatMap({$0.lastPathComponent})
        
        let deletedFileNames = modifiedFiles.deletedFiles.flatMap({$0.lastPathComponent})
        
        switch folder.observationType {
        case .added:
            
            if addedFileNames.count > 1 {
                notificationTitle = "\(addedFileNames.count) files added to \(folderName)"
                notificationBody = "\(addedFileNames[0]) and \(addedFileNames.count - 1) files were added."
            } else if addedFileNames.count == 1 {
                notificationTitle = "New file in \(folderName)"
                notificationBody = "\(addedFileNames[0]) was added"
            }
            
        case .deleted:
            
            if deletedFileNames.count > 1 {
                notificationTitle = "\(deletedFileNames.count) files deleted from \(folderName)"
                notificationBody = "\(deletedFileNames[0]) and \(deletedFileNames.count - 1) files were deleted"
            } else if deletedFileNames.count == 1 {
                notificationTitle = "Deleted file in \(folderName)"
                notificationBody = "\(deletedFileNames[0]) was deleted"
            }
            
            
        case .both:
            notificationTitle = "Both observation types not yet supported."
            notificationBody = "Something has changed in \(folderName)"
        
        default:
            break
        }
        
        
        
        let fileNotification = FileNotification(title: notificationTitle, body: notificationBody)
        
        CKContainer.default().privateCloudDatabase.save(fileNotification.cloudKitRecord) { (record, error) in
            if let error = error { NSLog(error.localizedDescription) }
            
            
        }
        
        
    }
    
    
    
    
}
