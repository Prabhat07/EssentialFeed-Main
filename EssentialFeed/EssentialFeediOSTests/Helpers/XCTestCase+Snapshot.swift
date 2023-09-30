//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Prabhat Tiwari on 30/09/23.
//

import XCTest

extension XCTestCase {
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storeSanpshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Fail to load stored snapshot at URL: \(snapshotURL), Use `record` method to store the snapshot before asserting", file: file, line: line)
            return
        }
        
        if snapshotData != storeSanpshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match the stored snapshot. New snapshot URL: \(temporarySnapshotURL) stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
            
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to reord snapshot with \(error)", file: file, line: line)
        }
        
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Fail to create PNG data representtio from snaeshot", file: file, line: line)
            return nil
        }
        return  data
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    
}
