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
    
    @discardableResult convenience init(urlString: String, folder: Folder, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.urlString = urlString
        self.folder = folder
    }
    
}
