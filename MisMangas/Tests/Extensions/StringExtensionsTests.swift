//
//  StringExtensionsTests.swift
//  MisMangas
//
//  Created by Claude Code on 26/2/26.
//

import XCTest
@testable import MisMangas

final class StringExtensionsTests: XCTestCase {
    
    // MARK: - cleanedURL Tests
    
    func testCleanedURLRemovesBackslashes() {
        let urlWithBackslashes = "https://example.com\\image\\path"
        let cleaned = urlWithBackslashes.cleanedURL
        
        XCTAssertFalse(cleaned.contains("\\"), "Should remove backslashes")
        XCTAssertEqual(cleaned, "https://example.com/image/path")
    }
    
    func testCleanedURLRemovesQuotes() {
        let urlWithQuotes = "\"https://example.com/image\""
        let cleaned = urlWithQuotes.cleanedURL
        
        XCTAssertFalse(cleaned.contains("\""), "Should remove quotes")
        XCTAssertEqual(cleaned, "https://example.com/image")
    }
    
    func testCleanedURLRemovesMultipleBackslashesAndQuotes() {
        let dirty = "\\\"https://example.com\\image\\file\\\""
        let cleaned = dirty.cleanedURL
        
        XCTAssertFalse(cleaned.contains("\\"), "Should remove all backslashes")
        XCTAssertFalse(cleaned.contains("\""), "Should remove all quotes")
    }
    
    func testCleanedURLWithCleanString() {
        let clean = "https://example.com/image"
        let result = clean.cleanedURL
        
        XCTAssertEqual(result, clean, "Should return same string when already clean")
    }
    
    func testCleanedURLWithEmptyString() {
        let empty = ""
        let result = empty.cleanedURL
        
        XCTAssertEqual(result, "", "Should handle empty string")
    }
    
    // MARK: - formattedDate Tests
    
    func testFormattedDateSimple() {
        let dateString = "1998-09-03"
        let formatted = dateString.formattedDate
        
        XCTAssertEqual(formatted, "03-09-1998", "Should format date correctly")
    }
    
    func testFormattedDateWithTime() {
        let dateString = "1998-09-03T12:30:00Z"
        let formatted = dateString.formattedDate
        
        XCTAssertEqual(formatted, "03-09-1998", "Should extract date part and format")
    }
    
    func testFormattedDateWithTimezone() {
        let dateString = "2023-12-25T14:30:00+02:00"
        let formatted = dateString.formattedDate
        
        XCTAssertEqual(formatted, "25-12-2023", "Should handle timezone in date")
    }
    
    func testFormattedDateDifferentYears() {
        let dates = [
            ("2000-01-01", "01-01-2000"),
            ("2025-12-31", "31-12-2025"),
            ("1990-06-15", "15-06-1990")
        ]
        
        for (input, expected) in dates {
            let formatted = input.formattedDate
            XCTAssertEqual(formatted, expected, "Should format \(input) correctly")
        }
    }
    
    func testFormattedDateInvalidFormat() {
        let invalidDate = "invalid-date"
        let formatted = invalidDate.formattedDate
        
        XCTAssertEqual(formatted, invalidDate, "Should return original string for invalid format")
    }
    
    func testFormattedDateMissingComponents() {
        let incompleteDate = "2023-05"
        let formatted = incompleteDate.formattedDate
        
        XCTAssertEqual(formatted, incompleteDate, "Should return original string if components missing")
    }
    
    func testFormattedDateWithExtraSpaces() {
        let dateWithSpaces = "1998 - 09 - 03"
        let formatted = dateWithSpaces.formattedDate
        
        // Should return original since format is not YYYY-MM-DD
        XCTAssertEqual(formatted, dateWithSpaces)
    }
    
    // MARK: - Combined Tests
    
    func testCleanedURLAndFormattedDateTogether() {
        let dirtyURL = "\"https://example.com/images\\2023-12-25T00:00:00Z\""
        let cleanedURL = dirtyURL.cleanedURL
        
        XCTAssertFalse(cleanedURL.contains("\\"), "URL should be cleaned")
        XCTAssertFalse(cleanedURL.contains("\""), "Quotes should be removed")
    }
    
    func testEdgeCaseEmptyAfterCleaning() {
        let onlySpecialChars = "\\\"\\\""
        let cleaned = onlySpecialChars.cleanedURL
        
        XCTAssertEqual(cleaned, "", "Should result in empty string")
    }
}
