//
//  BestMangasGridView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 13/2/26.
//

import SwiftUI
import SwiftData

struct BestMangasGridView: View {
    @Environment(\.modelContext) var context
    
    @State private var bestMangasVM = BestMangasViewModel()
    
    let namespace: Namespace.ID
    
    var body: some View {
            LazyHStack {
                ForEach(bestMangasVM.bestMangas) { manga in
                    NavigationLink(value: manga.toManga) {
                        MainPictureView(picture: manga.mainPictureURL, namespace: namespace)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 5)
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.leading)
            .scrollClipDisabled()
            .contentMargins(.horizontal, 30, for: .scrollContent)
        
        .task {
            await bestMangasVM.loadBestMangas()
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Namespace var namespace
    BestMangasGridView(namespace: namespace)
}


//if bestMangasVM.bestMangas.count > 1 {
//    ProgressView()
//        .onAppear {
//            let modelContainer = DataContainer(modelContainer: context.container)
//            Task.detached {
//                do {
//                    try await modelContainer.loadNextPage()
//                } catch {
//                    print(error)
//                }
//            }
//        }
//}
