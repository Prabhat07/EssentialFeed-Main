//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Prabhat Tiwari on 05/06/21.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedStore]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
        
    }
    
    private struct CodableFeedStore: Codable {
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
    
    private let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
           return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache  = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timeStamp: cache.timeStamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion:@escaping FeedStore.InsertCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedStore.init), timeStamp: timeStamp)
        let encode = try! encoder.encode(cache)
        try! encode.write(to: storeUrl)
        completion(nil)
    }

}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, got \(result) instead")
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
            switch (firstResult, secondResult) {
                case (.empty, .empty):
                break
            default:
                XCTFail("Expected retrieveing twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                
            }
            exp.fulfill()
        }
     }
        
        wait(for: [exp], timeout: 1.0)
    } 
    
    func test_retrieve_afterInsertingValueToEmptyCache_returnInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        let exp = expectation(description: "Wait for retrieve completion")

        sut.insert(feed, timeStamp: timeStamp)  { insertionError in
            
            XCTAssertNil(insertionError, "Feed inserted succesfullty")
            
            sut.retrieve { retrieveResult in
            switch retrieveResult {
            case let .found(retrieveFeed, retrieveTimeStamp):
                XCTAssertEqual(feed, retrieveFeed)
                XCTAssertEqual(timeStamp, retrieveTimeStamp)
                
                break
            default:
                XCTFail("Expected found result with feed \(feed) and timeStamp \(timeStamp), got \(retrieveResult) instead")

            }
            exp.fulfill()
        }
     }

        wait(for: [exp], timeout: 1.0)
    }

}
