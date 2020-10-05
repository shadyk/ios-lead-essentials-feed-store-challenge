//
//  Created by Shady
//  All rights reserved.
//  

import CoreData

@objc(ManagedFeed)
class ManagedFeed: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var descr: String?
    @NSManaged var location: String?
    @NSManaged var url: String
    @NSManaged var cache: ManagedCache

}

