//
//  KeychainManagerTests.swift
//  MisMangas
//
//  Created by Claude Code on 26/2/26.
//

import XCTest
@testable import MisMangas

final class KeychainManagerTests: XCTestCase {
    
    let keychain = KeychainManager.shared
    
    override func tearDown() {
        // Clean up after each test
        try? keychain.deleteToken()
        super.tearDown()
    }
    
    // MARK: - Token Storage Tests
    
    func testSaveAndRetrieveToken() async throws {
        let testToken = "test_jwt_token_12345"
        
        try keychain.saveToken(testToken)
        let retrievedToken = try keychain.getToken()
        
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match saved token")
    }
    
    func testGetTokenWhenEmpty() throws {
        // Delete token if exists
        try? keychain.deleteToken()
        
        let token = try keychain.getToken()
        XCTAssertNil(token, "Should return nil when no token exists")
    }
    
    func testUpdateToken() throws {
        let firstToken = "first_token"
        let secondToken = "second_token"
        
        try keychain.saveToken(firstToken)
        try keychain.saveToken(secondToken)
        
        let retrievedToken = try keychain.getToken()
        XCTAssertEqual(retrievedToken, secondToken, "Should return updated token")
    }
    
    func testDeleteToken() throws {
        let testToken = "test_token_to_delete"
        
        try keychain.saveToken(testToken)
        try keychain.deleteToken()
        
        let retrievedToken = try keychain.getToken()
        XCTAssertNil(retrievedToken, "Token should be nil after deletion")
    }
    
    // MARK: - Token Presence Tests
    
    func testHasTokenWhenSaved() async throws {
        let testToken = "test_token"
        try keychain.saveToken(testToken)
        
        let hasToken = await keychain.hasToken()
        XCTAssertTrue(hasToken, "Should have token after saving")
    }
    
    func testHasTokenWhenNotSaved() async throws {
        try? keychain.deleteToken()
        
        let hasToken = await keychain.hasToken()
        XCTAssertFalse(hasToken, "Should not have token when none saved")
    }
    
    // MARK: - Edge Cases
    
    func testSaveEmptyToken() throws {
        let emptyToken = ""
        
        try keychain.saveToken(emptyToken)
        let retrievedToken = try keychain.getToken()
        
        XCTAssertEqual(retrievedToken, emptyToken, "Should save empty token")
    }
    
    func testSaveLongToken() throws {
        let longToken = String(repeating: "a", count: 1000)
        
        try keychain.saveToken(longToken)
        let retrievedToken = try keychain.getToken()
        
        XCTAssertEqual(retrievedToken, longToken, "Should save and retrieve long token")
    }
    
    func testSaveSpecialCharactersToken() throws {
        let specialToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        
        try keychain.saveToken(specialToken)
        let retrievedToken = try keychain.getToken()
        
        XCTAssertEqual(retrievedToken, specialToken, "Should save JWT token with special characters")
    }
    
    // MARK: - Multiple Operations
    
    func testSequentialOperations() throws {
        let token1 = "token1"
        let token2 = "token2"
        
        // Save first token
        try keychain.saveToken(token1)
        XCTAssertEqual(try keychain.getToken(), token1)
        
        // Update to second token
        try keychain.saveToken(token2)
        XCTAssertEqual(try keychain.getToken(), token2)
        
        // Delete
        try keychain.deleteToken()
        XCTAssertNil(try keychain.getToken())
        
        // Save again
        try keychain.saveToken(token1)
        XCTAssertEqual(try keychain.getToken(), token1)
    }
    
    func testConcurrentOperations() async throws {
        let token = "concurrent_token"
        
        // Simulate concurrent access
        async let save = keychain.saveToken(token)
        async let _ = save
        
        let retrievedToken = try keychain.getToken()
        XCTAssertEqual(retrievedToken, token, "Should handle concurrent operations")
    }
}
