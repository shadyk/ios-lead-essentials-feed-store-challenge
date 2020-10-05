//
//  Created by Shady
//  All rights reserved.
//  

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var feed: NSOrderedSet
    @NSManaged var timestamp: Date
}


extension ManagedCache {
    var localFeed : [LocalFeedImage] {
        let managedFeeds = feed.array as! [ManagedFeed]
        return managedFeeds.map{LocalFeedImage(id: $0.id, description: $0.descr, location: $0.location, url: URL(string:$0.url)!)}
    }

}
