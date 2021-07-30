//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Prabhat Tiwari on 10/07/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
        
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
    }
    
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInteractive)
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.empty)
            }
            do {
                let decoder = JSONDecoder()
                let cache  = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping InsertCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
                let encode = try encoder.encode(cache)
                try encode.write(to: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCacheFeed(completion:@escaping DeleteCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

}
