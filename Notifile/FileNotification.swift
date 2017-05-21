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
    
    private let titleKey = "title"
    private let bodyKey = "body"
    
    let title: String
    let body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: FileNotification.typeKey)
        
        record.setValue(title, forKey: titleKey)
        record.setValue(body, forKey: bodyKey)
        
        return record
    }
    
}
