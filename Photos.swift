//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Olivia Murphy on 8/23/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

import Foundation
import CoreData


class Photos: NSManagedObject {
    convenience init(url: String, data: NSData?, context : NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Photos",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.url = url
            self.data = data
            
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    

}
