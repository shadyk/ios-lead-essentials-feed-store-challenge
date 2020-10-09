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
        do  {
            try ManagedCache.cleanCurrentCache(in: self.context)
            completion(nil)
        }
        catch {
            completion(error)
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            try ManagedCache.createNew(feed: feed, timestamp: timestamp, context: self.context)
            try self.context.save()
            completion(nil)
        }
        catch{
            completion(error)
        }
    }


    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            if let managedCache = try ManagedCache.getCurrentCache(in:context) {
                completion(.found(feed: managedCache.localFeed, timestamp: managedCache.timestamp))
            }
            else {
                completion(.empty)
            }

        } catch {
            completion(.failure(error))
        }
    }
}
