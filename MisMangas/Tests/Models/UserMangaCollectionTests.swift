//
//  UserMangaCollectionTests.swift
//  MisMangas
//
//  Created by Claude Code on 26/2/26.
//

import XCTest
@testable import MisMangas

final class UserMangaCollectionTests: XCTestCase {
    
    var collection: UserMangaCollection!
    
    override func setUp() {
        super.setUp()
        collection = UserMangaCollection(
            mangaID: 1,
            readingVolume: nil,
            completeCollection: false,
            volumesOwned: []
        )
    }
    
    override func tearDown() {
        collection = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(collection.mangaID, 1, "Manga ID should be 1")
        XCTAssertNil(collection.readingVolume, "Reading volume should be nil initially")
        XCTAssertFalse(collection.completeCollection, "Complete collection should be false")
        XCTAssertTrue(collection.volumesOwned.isEmpty, "Volumes owned should be empty")
    }
    
    // MARK: - Volume Management Tests
    
    func testAddVolume() {
        collection.addVolume(1)
        
        XCTAssertTrue(collection.volumesOwned.contains(1), "Volume 1 should be added")
        XCTAssertEqual(collection.volumesOwnedCount, 1, "Owned volumes count should be 1")
    }
    
    func testAddMultipleVolumes() {
        collection.addVolumes([1, 2, 3, 4, 5])
        
        XCTAssertEqual(collection.volumesOwnedCount, 5, "Should have 5 volumes")
        XCTAssertTrue(collection.volumesOwned.contains(1), "Should contain volume 1")
        XCTAssertTrue(collection.volumesOwned.contains(5), "Should contain volume 5")
    }
    
    func testRemoveVolume() {
        collection.addVolumes([1, 2, 3])
        collection.removeVolume(2)
        
        XCTAssertFalse(collection.volumesOwned.contains(2), "Volume 2 should be removed")
        XCTAssertEqual(collection.volumesOwnedCount, 2, "Should have 2 volumes left")
    }
    
    func testVolumesSorted() {
        collection.addVolumes([5, 2, 1, 4, 3])
        let sortedVolumes = collection.volumesOwned
        
        XCTAssertEqual(sortedVolumes, [1, 2, 3, 4, 5], "Volumes should be sorted")
    }
    
    func testOwnsVolume() {
        collection.addVolumes([1, 2, 3])
        
        XCTAssertTrue(collection.ownsVolume(2), "Should own volume 2")
        XCTAssertFalse(collection.ownsVolume(4), "Should not own volume 4")
    }
    
    func testNoDuplicateVolumes() {
        collection.addVolume(1)
        let countBefore = collection.volumesOwnedCount
        
        collection.addVolume(1) // Add again
        let countAfter = collection.volumesOwnedCount
        
        XCTAssertEqual(countBefore, countAfter, "Should not add duplicate volumes")
    }
    
    // MARK: - Reading Progress Tests
    
    func testSetReadingVolume() {
        collection.readingVolume = 3
        
        XCTAssertEqual(collection.readingVolume, 3, "Reading volume should be set")
        XCTAssertTrue(collection.hasStartedReading, "Should have started reading")
    }
    
    func testReadingProgressCalculation() {
        collection.addVolumes([1, 2, 3, 4, 5])
        collection.readingVolume = 3
        
        let progress = collection.readingProgress(totalVolumes: 5)
        XCTAssertNotNil(progress, "Progress should not be nil")
        XCTAssertEqual(progress, 0.6, accuracy: 0.01, "Progress should be 60%")
    }
    
    func testReadingProgressEdgeCases() {
        // Progress at start
        collection.readingVolume = 1
        let progressStart = collection.readingProgress(totalVolumes: 5)
        XCTAssertEqual(progressStart, 0.2, accuracy: 0.01, "Progress at volume 1 should be 20%")
        
        // Progress at end
        collection.readingVolume = 5
        let progressEnd = collection.readingProgress(totalVolumes: 5)
        XCTAssertEqual(progressEnd, 1.0, accuracy: 0.01, "Progress at volume 5 should be 100%")
    }
    
    func testReadingProgressWithNilTotalVolumes() {
        collection.readingVolume = 3
        let progress = collection.readingProgress(totalVolumes: nil)
        
        XCTAssertNil(progress, "Progress should be nil when total volumes is nil")
    }
    
    // MARK: - Collection Progress Tests
    
    func testCollectionProgressCalculation() {
        collection.addVolumes([1, 2, 3])
        
        let progress = collection.collectionProgress(totalVolumes: 5)
        XCTAssertNotNil(progress, "Collection progress should not be nil")
        XCTAssertEqual(progress, 0.6, accuracy: 0.01, "Collection progress should be 60%")
    }
    
    func testCollectionProgressComplete() {
        collection.completeCollection = true
        
        let progress = collection.collectionProgress(totalVolumes: 10)
        XCTAssertEqual(progress, 1.0, accuracy: 0.01, "Complete collection should be 100%")
    }
    
    // MARK: - Sync Management Tests
    
    func testMarkAsPendingSync() {
        collection.markAsPendingSync(operation: .add)
        
        XCTAssertTrue(collection.isPendingSync, "Should be marked as pending sync")
        XCTAssertEqual(collection.pendingSyncOperation, "add", "Operation should be 'add'")
    }
    
    func testMarkAsSynced() {
        collection.markAsPendingSync(operation: .update)
        collection.markAsSynced()
        
        XCTAssertFalse(collection.isPendingSync, "Should be marked as synced")
        XCTAssertNil(collection.pendingSyncOperation, "Operation should be nil after sync")
    }
    
    // MARK: - Dates Tests
    
    func testDateAddedSet() {
        let dateAdded = collection.dateAdded
        
        XCTAssertNotNil(dateAdded, "Date added should be set")
        XCTAssertLessThanOrEqual(abs(dateAdded.timeIntervalSinceNow), 1, "Date added should be recent")
    }
    
    func testLastUpdatedChangesOnVolumeChange() {
        let initialLastUpdated = collection.lastUpdated
        
        // Wait a tiny bit and add volume
        usleep(100000) // 100ms
        collection.addVolume(1)
        
        let newLastUpdated = collection.lastUpdated
        XCTAssertGreaterThan(newLastUpdated, initialLastUpdated, "Last updated should change")
    }
    
    // MARK: - Clear Volumes Test
    
    func testClearVolumes() {
        collection.addVolumes([1, 2, 3, 4, 5])
        collection.clearVolumes()
        
        XCTAssertTrue(collection.volumesOwned.isEmpty, "Volumes should be cleared")
        XCTAssertEqual(collection.volumesOwnedCount, 0, "Volumes owned count should be 0")
    }
    
    func testSetVolumes() {
        let newVolumes = [2, 4, 6, 8]
        collection.setVolumes(newVolumes)
        
        XCTAssertEqual(collection.volumesOwned, newVolumes, "Volumes should be replaced")
        XCTAssertEqual(collection.volumesOwnedCount, 4, "Should have 4 volumes")
    }
}
