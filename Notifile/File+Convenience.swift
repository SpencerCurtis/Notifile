//
//  File+Convenience.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

extension File {
    
    @discardableResult convenience init(url: URL, folder: Folder, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.urlString = url.absoluteString
        self.folder = folder
    }
    
}
