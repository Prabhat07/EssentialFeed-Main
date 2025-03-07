//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Prabhat Tiwari on 09/07/22.
//

import Foundation
import Combine
import EssentialFeed


public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(from url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
    
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
    
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
               task = loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
    
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput:{ data in
            cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache  {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}


extension Publisher where Output == [FeedImage] {
    func caching(with cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput:cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch({ _ in fallbackPublisher() }).eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainThread() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainThreadScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueSheduler: ImmediateWhenOnMainQueueSheduler {
        return ImmediateWhenOnMainQueueSheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueSheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return  DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
    }
    
    static var immediateWhenOnMainThreadScheduler: ImmediateWhenOnMainThreadScheduler {
            ImmediateWhenOnMainThreadScheduler()
        }
        
        struct ImmediateWhenOnMainThreadScheduler: Scheduler {
            typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
            typealias SchedulerOptions = DispatchQueue.SchedulerOptions
            
            var now: SchedulerTimeType {
                DispatchQueue.main.now
            }
            
            var minimumTolerance: SchedulerTimeType.Stride {
                DispatchQueue.main.minimumTolerance
            }
            
            func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
                guard Thread.isMainThread else {
                    return DispatchQueue.main.schedule(options: options, action)
                }
                
                action()
            }
            
            func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
                DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
            }
            
            func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
                DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
            }
        }
    
}
