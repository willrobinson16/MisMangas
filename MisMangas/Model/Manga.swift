////
////  Manga.swift
////  MisMangas
////
////  Created by Guillermo Robinson on 16/2/26.
////
//
//import Foundation
//
///// Manga model matching MangaDTO structure
//struct Manga: Codable, Identifiable, Hashable {
//    let id: Int
//    let status: MangaStatus
//    let background: String?
//    let title: String
//    let titleEnglish: String?
//    let titleJapanese: String?
//    let score: Double
//    let chapters: Int?
//    let startDate: String?
//    let themes: [Theme]
//    let mainPicture: String?
//    let authors: [Author]
//    let synopsis: String?
//    let url: String?
//    let genres: [Genre]
//    let volumes: Int?
//    let endDate: String?
//    let demographics: [Demographic]
//}
////MARK: - Manga formatters
//extension Manga {
//    var scoreS: String {
//        score.formatted(.number.precision(.integerAndFractionLength(integer: 1, fraction: 2)))
//    }
//
//    var authorsString: String {
//        authors.map { "\($0.firstName) \($0.lastName)" }.joined(separator: ", ")
//    }
//
//    var authorsWithRole: String {
//        authors.map { "\($0.firstName) \($0.lastName) (\($0.role.rawValue))" }.joined(separator: " • ")
//    }
//
//    var mainPictureURL: URL? {
//        mainPicture.flatMap { URL(string: $0.cleanedURL) }
//    }
//
//    var urlCleaned: URL? {
//        url.flatMap { URL(string: $0.cleanedURL) }
//    }
//
//    /// Test manga
//    static let test = Manga(
//        id: 13,
//        status: .currentlyPublishing,
//        background: "One Piece is the best-selling manga series in history, with over 500 million copies in circulation worldwide.",
//        title: "One Piece",
//        titleEnglish: "One Piece",
//        titleJapanese: "ワンピース",
//        score: 9.21,
//        chapters: 1100,
//        startDate: "1997-07-25T00:00:00Z",
//        themes: [
//            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440002")!, theme: "Adventure")
//        ],
//        mainPicture: "https://cdn.myanimelist.net/images/manga/2/253146.jpg",
//        authors: [
//            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440000")!, firstName: "Eiichiro", lastName: "Oda", role: .storyAndArt)
//        ],
//        synopsis: "Gol D. Roger was known as the Pirate King, the strongest and most infamous being to have sailed the Grand Line. The capture and execution of Roger by the World Government brought a change throughout the world. His last words before his death revealed the existence of the greatest treasure in the world, One Piece.",
//        url: "https://myanimelist.net/manga/13/One_Piece",
//        genres: [
//            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440001")!, genre: "Action")
//        ],
//        volumes: 107,
//        endDate: nil,
//        demographics: [
//            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440003")!, demographic: "Shounen")
//        ]
//    )
//}
