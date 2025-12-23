HStack {
                            VStack(alignment: .leading) {
                                Text(manga.title)
                                    .font(.headline)
                                Text(manga.authorsString)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 20)
                            AsyncImage(url: manga.mainPicture) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 150)
                                    .clipShape(.rect(cornerRadius: 11))
                            } placeholder: {
                                Image(systemName: "book")
                            }
                        }
                        .padding(.horizontal)