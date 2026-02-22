////
////  FavoritesView.swift
////  MisMangas
////
////  Created by Guillermo Robinson on 6/1/26.
////
//
//import SwiftUI
//import SwiftData
//
//struct FavoritesView: View {
//    @Environment(FavoritesViewModel.self) private var favoritesVM
//    
//    @Query private var mangas: [Manga]
//    @Query private var favoriteMangas: [FavoriteManga]
//    
//    @Namespace private var namespace
//    
//    private var favorites: [Manga] {
////        let favoriteIDs = Set(favoriteMangas.map { $0.id })
//        let favoritesDict = Dictionary(uniqueKeysWithValues: favoriteMangas.map { ($0.id, $0.dataAdded) })
//
//        return mangas
////            .filter { favoriteIDs.contains($0.id) }
////            .filter { favoritesDict[$0.id] != nil }
//            .filter { favoritesDict.keys.contains($0.id) }
//            .sorted { favoritesDict[$0.id] ?? .distantPast > favoritesDict[$1.id] ?? .distantPast }
////            .sorted { favoritesDict[$0.id] ?? .distantPast > favoritesDict[$1.id] ?? .distantPast }
//            
//            
//    }
//    
//    private var favoriteIDs: Set<Int> {
//        Set(favoriteMangas.map { $0.id })
//    }
//    
//    var body: some View {
//        NavigationStack {
//            Group {
//                if favorites.isEmpty {
//                    ContentUnavailableView("Favoritos", systemImage: "heart.circle", description: Text("Aún no has añadido mangas a favoritos"))
//                } else {
//                    List {
//                        ForEach(favorites) { manga in
//                            NavigationLink(value: manga) {
//                                MangaRow(manga: manga, namespace: namespace)
//                            }
//                            .swipeActions {
//                                Button(role: .destructive) {
//                                    favoritesVM.removeFavorite(manga.id)
//                                } label: {
//                                    Image(systemName: "trash")
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    .listStyle(.plain)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .navigationTitle("Favoritos")
//            .navigationDestination(for: Manga.self) { manga in
//                MangaView(manga: manga, namespace: namespace)
//            }
//        }
//    }
//}
//
//#Preview(traits: .sampleData) {
//    NavigationStack {
//        FavoritesView()
//            .environment(FavoritesViewModel())
//            .modelContainer(for: FavoriteManga.self)
//    }
//}
