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

    static func createNew(feed:[LocalFeedImage], timestamp: Date, context: NSManagedObjectContext){
        cleanCurrentCache(in: context)
        let managedCache = ManagedCache(context: context)
        var managedFeeds = [ManagedFeed]()
        for localFeedImage in feed {
            let feedImage = ManagedFeed(context: context)
            feedImage.id = localFeedImage.id
            feedImage.descr = localFeedImage.description
            feedImage.location = localFeedImage.location
            feedImage.url = localFeedImage.url.absoluteString
            feedImage.cache = managedCache
            managedFeeds.append(feedImage)
        }
        managedCache.feed = NSOrderedSet(array: managedFeeds)
        managedCache.timestamp = timestamp
    }

    static func getCurrentCache(in context:NSManagedObjectContext) throws -> ManagedCache?{
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func cleanCurrentCache(in context:NSManagedObjectContext){
        do{
            try getCurrentCache(in: context).map(context.delete)
        }
        catch{
            print("error in cleaning \(error)")
        }
    }


}
