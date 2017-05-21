//
//  FileModificationNotification.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/20/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CloudKit

class FileNotification {
    
    static let typeKey = "FilesNotification"
    
    static let titleKey = "title"
    static let bodyKey = "body"
    static let uuidKey = "uuid"
    
    let title: String
    let body: String
    let uuid: String
    
    init(title: String, body: String, uuid: String = UUID().uuidString) {
        self.title = title
        self.body = body
        self.uuid = uuid
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: FileNotification.typeKey)
        
        record.setValue(title, forKey: FileNotification.titleKey)
        record.setValue(body, forKey: FileNotification.bodyKey)
        record.setValue(uuid, forKey: FileNotification.uuidKey)
        
        return record
    }
    
}
