//
//  Author.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import Foundation

/// Author model matching AuthorDTO structure
struct Author: Codable, Identifiable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let role: AuthorRole
}

extension Author {
    /// Test authors
    static let eiichiroOda = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440000")!,
        firstName: "Eiichiro",
        lastName: "Oda",
        role: .storyAndArt
    )

    static let masashiKishimoto = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440012")!,
        firstName: "Masashi",
        lastName: "Kishimoto",
        role: .storyAndArt
    )

    static let tsugumiOhba = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440022")!,
        firstName: "Tsugumi",
        lastName: "Ohba",
        role: .story
    )

    static let takeshiObata = Author(
        id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440023")!,
        firstName: "Takeshi",
        lastName: "Obata",
        role: .art
    )

    static let test = [eiichiroOda, masashiKishimoto, tsugumiOhba, takeshiObata]
}
