//
//  AuthorRow.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/1/26.
//

import SwiftUI

struct AuthorRow: View {
    let authors: [Author]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(authors) { author in
                HStack {
                    Text(author.firstName)
                    Text(author.lastName)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    AuthorRow(authors: Author.test)
}
