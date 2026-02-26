//
//  SearchViewModelTests.swift
//  MisMangas
//
//  Created by Claude Code on 26/2/26.
//

import XCTest
@testable import MisMangas

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Filter Management Tests
    
    func testAddGenreFilter() {
        let genre = "Action"
        viewModel.selectedGenres.insert(genre)
        
        XCTAssertTrue(viewModel.selectedGenres.contains(genre), "Genre should be added")
        XCTAssertTrue(viewModel.hasActiveFilters, "Should have active filters")
    }
    
    func testRemoveGenreFilter() {
        let genre = "Action"
        viewModel.selectedGenres.insert(genre)
        viewModel.selectedGenres.remove(genre)
        
        XCTAssertFalse(viewModel.selectedGenres.contains(genre), "Genre should be removed")
        XCTAssertFalse(viewModel.hasActiveFilters, "Should not have active filters")
    }
    
    func testMultipleGenreFilters() {
        let genres = ["Action", "Adventure", "Comedy"]
        for genre in genres {
            viewModel.selectedGenres.insert(genre)
        }
        
        XCTAssertEqual(viewModel.selectedGenres.count, 3, "Should have 3 genres")
        XCTAssertEqual(viewModel.activeFiltersCount, 3, "Active filters count should be 3")
    }
    
    // MARK: - Search Title Tests
    
    func testSearchTitleEmptyInitially() {
        XCTAssertTrue(viewModel.searchTitle.isEmpty, "Search title should be empty initially")
    }
    
    func testSetSearchTitle() {
        let title = "One Piece"
        viewModel.searchTitle = title
        
        XCTAssertEqual(viewModel.searchTitle, title, "Search title should be set")
        XCTAssertTrue(viewModel.hasActiveFilters, "Should have active filters")
    }
    
    // MARK: - Filter State Tests
    
    func testHasActiveFiltersWithTitle() {
        viewModel.searchTitle = "Test"
        XCTAssertTrue(viewModel.hasActiveFilters, "Should have active filters with title")
    }
    
    func testHasActiveFiltersWithGenres() {
        viewModel.selectedGenres.insert("Action")
        XCTAssertTrue(viewModel.hasActiveFilters, "Should have active filters with genres")
    }
    
    func testHasActiveFiltersWithAuthor() {
        viewModel.authorFirstName = "John"
        XCTAssertTrue(viewModel.hasActiveFilters, "Should have active filters with author")
    }
    
    func testActiveFiltersCount() {
        viewModel.searchTitle = "Test"
        viewModel.selectedGenres.insert("Action")
        viewModel.selectedThemes.insert("Magic")
        
        let count = viewModel.activeFiltersCount
        XCTAssertGreaterThan(count, 0, "Active filters count should be greater than 0")
    }
    
    // MARK: - Search State Tests
    
    func testInitialSearchState() {
        XCTAssertTrue(viewModel.mangaResult.isEmpty, "Initial search results should be empty")
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(viewModel.errorMessage, "Initial error message should be nil")
    }
    
    // MARK: - Use Contains Toggle
    
    func testUseContainsToggle() {
        let initialState = viewModel.useContains
        viewModel.useContains.toggle()
        
        XCTAssertNotEqual(initialState, viewModel.useContains, "Use contains state should be toggled")
    }
}
