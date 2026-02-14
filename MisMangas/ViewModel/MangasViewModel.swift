////
////  MangasViewModel.swift
////  MisMangas
////
////  Created by Guillermo Robinson on 12/2/26.
////
//
//import Foundation
//
//@Observable @MainActor
//final class MangasViewModel {
//    let repository: NetworkRepository
//    
//    var mangas: [Manga]
//    var state: ViewState = .loading
//    var showError: Bool = false
//    var errorMsg: String = ""
//    
//    var bestMangas: [Manga] {
//        mangas
//            .sorted { $0.score > $1.score }
//            .prefix(5)
//            .map { $0 }
//    }
//    
//    init(repository: NetworkRepository = NetworkRepository()) {
//        self.repository = repository
//    }
//    
//    func getMangas() async {
//        guard mangas.isEmpty else { return }
//        state = .loading
//        do {
//            self.mangas = try await repository.getMangas()
//            state = mangas.isEmpty ? .empty : .loaded
//        } catch {
//            errorMsg = error.localizedDescription
//            showError.toggle()
//            state = .empty
//        }
//    }
//}
//
//enum ViewState {
//    case loading
//    case loaded
//    case empty
//}
