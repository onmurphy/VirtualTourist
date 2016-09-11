//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 9/10/16.
//  Copyright © 2016 Murphy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photos {

    @NSManaged var url: String?
    @NSManaged var pin: Pin?

}
