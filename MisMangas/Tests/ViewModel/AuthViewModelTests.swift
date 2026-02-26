//
//  AuthViewModelTests.swift
//  MisMangas
//
//  Created by Claude Code on 26/2/26.
//

import XCTest
@testable import MisMangas

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AuthViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testValidEmailFormat() {
        let validEmails = [
            "user@example.com",
            "test.user@example.com",
            "user+tag@example.co.uk"
        ]
        
        for email in validEmails {
            let isValid = viewModel.isValidEmail(email)
            XCTAssertTrue(isValid, "Email \(email) should be valid")
        }
    }
    
    func testInvalidEmailFormat() {
        let invalidEmails = [
            "plaintext",
            "@example.com",
            "user@",
            "user@.com",
            "user name@example.com"
        ]
        
        for email in invalidEmails {
            let isValid = viewModel.isValidEmail(email)
            XCTAssertFalse(isValid, "Email \(email) should be invalid")
        }
    }
    
    // MARK: - Error Message Handling
    
    func testClearErrorMessage() {
        viewModel.errorMessage = "Test error"
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil after clearing")
    }
    
    func testInitialAuthenticationState() {
        XCTAssertFalse(viewModel.isAuthenticated, "Initial state should not be authenticated")
        XCTAssertNil(viewModel.currentUser, "Initial user should be nil")
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
    }
    
    // MARK: - Private Helper
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
