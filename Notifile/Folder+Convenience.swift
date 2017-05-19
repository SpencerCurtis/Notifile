//
//  Folder+Convenience.swift
//  Notifile
//
//  Created by Spencer Curtis on 5/18/17.
//  Copyright © 2017 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreData

enum ObservationType: String {
    case added = "Added"
    case deleted = "Deleted"
    case both = "Both"
    case none = "None"
}

extension Folder {
    
    @discardableResult convenience init(url: URL, observationType: ObservationType, isObserving: Bool = false, hasObserver: Bool = false, files: [URL] = [], context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.isObserving = isObserving
        self.hasObserver = hasObserver
        self.urlString = url.absoluteString
        self.observationTypeString = observationType.rawValue
    }
    
    var observationType: ObservationType {
        guard let observationTypeString = self.observationTypeString else { return .none }
        return ObservationType(rawValue: observationTypeString) ?? .none
    }
    
    var url: URL? {
        return URL(string: urlString ?? "")
    }
}
