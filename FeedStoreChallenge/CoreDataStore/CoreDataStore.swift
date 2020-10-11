//
//  Created by Shady
//  All rights reserved.
//  

import CoreData

open class CoreDataStore : FeedStore{
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
        container = try NSPersistentContainer.load(name: storeName, model: model, url:storeURL)
        context = container.newBackgroundContext()

    }

    open func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            do  {
                try ManagedCache.cleanCurrentCache(in: self.context)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }

    open func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform {
            do {
                try ManagedCache.createNew(feed: feed, timestamp: timestamp, context: self.context)
                try self.context.save()
                completion(nil)
            }
            catch{
                completion(error)
            }
        }

    }


    open func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform {
            do {
                if let managedCache = try ManagedCache.getCurrentCache(in:self.context) {
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
}
