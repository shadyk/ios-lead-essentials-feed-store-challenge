//
//  Created by Shady
//  All rights reserved.
//  

import CoreData

public class CoreDataStore : FeedStore{
    enum ModelError : Error {
        case modelNotFound
    }
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    private static let modelName = "FeedModel"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataStore.self))

    public init(storeURL:URL,storeName:String) throws{
        guard let model = CoreDataStore.model else {
            throw ModelError.modelNotFound
        }
        do {
            container = try NSPersistentContainer.load(name: storeName, model: model, url:storeURL)
            context = container.newBackgroundContext()
        }
        catch{
            throw error
        }

    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform {
            do {
                let managedCache = ManagedCache(context: self.context)
                var managedFeeds = [ManagedFeed]()
                for localFeedImage in feed {
                    let feedImage = ManagedFeed(context: self.context)
                    feedImage.id = localFeedImage.id
                    feedImage.descr = localFeedImage.description
                    feedImage.location = localFeedImage.location
                    feedImage.url = localFeedImage.url.absoluteString
                    feedImage.cache = managedCache
                    managedFeeds.append(feedImage)
                }

                managedCache.feed = NSOrderedSet(array: managedFeeds)
                managedCache.timestamp = timestamp
                try self.context.save()
                completion(nil)
            }
            catch{
                completion(error)
            }
        }

    }


    public func retrieve(completion: @escaping RetrievalCompletion) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ManagedCache")
          do {
            if let result = try context.fetch(fetchRequest).first {
                let managedCahe = result as! ManagedCache
                completion(.found(feed: managedCahe.localFeed, timestamp: managedCahe.timestamp))
            }
            else {
                completion(.empty)
            }

          } catch let error as NSError {
            completion(.failure(error))
            print("Could not fetch. \(error), \(error.userInfo)")
          }
    }

    //MARK: - HELPERS

//    private func insertCache(cache:MangagedCache) throws{
//        let context = container.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Cache", in: context)!
//        let managedObj = NSManagedObject(entity: entity, insertInto: context)
//        managedObj.setValue(timestamp, forKeyPath: "timestamp")
//        managedObj.setValue(NSSet(array: feed), forKeyPath: "feed")
//        try context.save()
//    }
//
//    private func insertDetails(id:UUID,descr:String?,location:String?,url:String) throws{
//        let context = container.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Feed", in: context)!
//        let managedObj = NSManagedObject(entity: entity, insertInto: context)
//
//        managedObj.setValue(id, forKeyPath: "id")
//        managedObj.setValue(descr, forKeyPath: "descr")
//        managedObj.setValue(location, forKeyPath: "location")
//        managedObj.setValue(url, forKeyPath: "url")
//        try context.save()
//    }
}
