//
//  PreviewData.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 10/12/25.
//

import Foundation
import SwiftData

extension Manga {
    /// Naruto - Manga de acción y aventuras ninja
    @MainActor static let naruto = Manga(
        id: 11,
        status: "finished",
        background: "Naruto became one of the best-selling manga series in history with over 250 million copies in circulation worldwide. It spawned a massive franchise including anime, movies, and video games.",
        title: "Naruto",
        titleEnglish: "Naruto",
        titleJapanese: "NARUTO -ナルト-",
        score: 8.12,
        chapters: 700,
        startDate: "1999-09-21T00:00:00Z",
        endDate: "2014-11-10T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/3/249658.jpg"),
        synopsis: "Naruto Uzumaki, a hyperactive and knuckle-headed ninja, lives in Konohagakure, the Hidden Leaf village. Moments prior to his birth, a huge demon known as the Kyuubi, the Nine-tailed Fox, attacked Konohagakure and wreaked havoc. In order to put an end to the Kyuubi's rampage, the leader of the village sealed the beast inside Naruto's body.",
        url: URL(string: "https://myanimelist.net/manga/11/Naruto"),
        volumes: 72,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440010")!, theme: "Martial Arts"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440011")!, theme: "Super Power")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440012")!, firstName: "Masashi", lastName: "Kishimoto", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440013")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440014")!, genre: "Adventure"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440015")!, genre: "Fantasy")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440016")!, demographic: "Shounen")
        ]
    )
    
    /// Death Note - Thriller psicológico sobrenatural
    @MainActor static let deathNote = Manga(
        id: 21,
        status: "finished",
        background: "Death Note was adapted into a highly successful anime series and spawned multiple live-action films. It is known for its psychological battles and moral questions about justice.",
        title: "Death Note",
        titleEnglish: "Death Note",
        titleJapanese: "デスノート",
        score: 8.70,
        chapters: 108,
        startDate: "2003-12-01T00:00:00Z",
        endDate: "2006-05-15T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/2/253153.jpg"),
        synopsis: "Light Yagami is an ace student with great prospects—and he's bored out of his mind. One day he finds the Death Note, a notebook held by a shinigami. With the Death Note in hand, Light decides to create a perfect world. A world without crime or criminals. But when criminals start dropping dead one by one, the authorities send a brilliant detective known as L to track down the killer.",
        url: URL(string: "https://myanimelist.net/manga/21/Death_Note"),
        volumes: 12,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440020")!, theme: "Psychological"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440021")!, theme: "Supernatural")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440022")!, firstName: "Tsugumi", lastName: "Ohba", role: "Story"),
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440023")!, firstName: "Takeshi", lastName: "Obata", role: "Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440024")!, genre: "Mystery"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440025")!, genre: "Supernatural"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440026")!, genre: "Thriller")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440027")!, demographic: "Shounen")
        ]
    )
    
    /// Attack on Titan - Dark fantasy post-apocalíptico
    @MainActor static let attackOnTitan = Manga(
        id: 53390,
        status: "finished",
        background: "Attack on Titan became a cultural phenomenon, praised for its intricate plot and shocking revelations. The series concluded after 11 years of serialization.",
        title: "Shingeki no Kyojin",
        titleEnglish: "Attack on Titan",
        titleJapanese: "進撃の巨人",
        score: 8.55,
        chapters: 139,
        startDate: "2009-09-09T00:00:00Z",
        endDate: "2021-04-09T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/2/37846.jpg"),
        synopsis: "In this post-apocalyptic sci-fi story, humanity has been devastated by the bizarre, giant humanoids known as the Titans. Little is known about where they came from or why they are bent on consuming mankind. For the past century, what's left of man has hidden in a giant, three-walled city. People believe their 50-meter-high walls will protect them from the Titans, but the sudden appearance of an immense Titan is about to change everything.",
        url: URL(string: "https://myanimelist.net/manga/53390/Shingeki_no_Kyojin"),
        volumes: 34,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440030")!, theme: "Military"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440031")!, theme: "Survival")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440032")!, firstName: "Hajime", lastName: "Isayama", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440033")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440034")!, genre: "Drama"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440035")!, genre: "Fantasy")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440036")!, demographic: "Shounen")
        ]
    )
    
    /// Berserk - Dark fantasy épico
    @MainActor static let berserk = Manga(
        id: 2,
        status: "on_hiatus",
        background: "Berserk is widely regarded as one of the greatest manga of all time, known for its dark themes, complex characters, and stunning artwork. The series went on hiatus following the death of its creator Kentarou Miura in 2021, but was later continued under supervision of his close friend and fellow mangaka.",
        title: "Berserk",
        titleEnglish: "Berserk",
        titleJapanese: "ベルセルク",
        score: 9.47,
        chapters: 380,
        startDate: "1989-08-25T00:00:00Z",
        endDate: "2021-05-21T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/1/157897.jpg"),
        synopsis: "Guts, a former mercenary now known as the Black Swordsman, is out for revenge. After a tumultuous childhood, he finally finds someone he respects and believes he can trust, only to have everything fall apart when this person takes away everything important to Guts for the purpose of fulfilling his own desires. Now marked for death, Guts becomes condemned to a fate in which he is relentlessly pursued by demonic beings.",
        url: URL(string: "https://myanimelist.net/manga/2/Berserk"),
        volumes: 41,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440040")!, theme: "Gore"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440041")!, theme: "Military"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440042")!, theme: "Mythology")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440043")!, firstName: "Kentarou", lastName: "Miura", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440044")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440045")!, genre: "Adventure"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440046")!, genre: "Drama"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440047")!, genre: "Fantasy"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440048")!, genre: "Horror")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440049")!, demographic: "Seinen")
        ]
    )
    
    /// Fullmetal Alchemist - Aventura steampunk de alquimia
    @MainActor static let fullmetalAlchemist = Manga(
        id: 25,
        status: "finished",
        background: "Fullmetal Alchemist won numerous awards including the Shogakukan Manga Award. It has been praised for its deep themes, well-developed characters, and intricate plot.",
        title: "Fullmetal Alchemist",
        titleEnglish: "Fullmetal Alchemist",
        titleJapanese: "鋼の錬金術師",
        score: 9.06,
        chapters: 116,
        startDate: "2001-07-12T00:00:00Z",
        endDate: "2010-09-11T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/3/243675.jpg"),
        synopsis: "Alchemists are knowledgeable and naturally talented individuals who can manipulate and modify matter due to their art. Yet despite the wide range of possibilities, alchemy is not as all-powerful as most would believe. Human transmutation is strictly forbidden, and whoever attempts it risks severe consequences. Even so, siblings Edward and Alphonse Elric decide to ignore this ban and bring their mother back to life. Unfortunately, not only do they fail in resurrecting her, they also pay an extremely high price for their arrogance.",
        url: URL(string: "https://myanimelist.net/manga/25/Fullmetal_Alchemist"),
        volumes: 27,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440050")!, theme: "Military")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440051")!, firstName: "Hiromu", lastName: "Arakawa", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440052")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440053")!, genre: "Adventure"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440054")!, genre: "Drama"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440055")!, genre: "Fantasy")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440056")!, demographic: "Shounen")
        ]
    )
    
    /// Fruits Basket - Romance shoujo con drama sobrenatural
    @MainActor static let fruitsBasket = Manga(
        id: 120,
        status: "finished",
        background: "Fruits Basket is one of the best-selling shoujo manga series and has been adapted multiple times into anime. It has won multiple awards and is praised for its emotional depth and character development.",
        title: "Fruits Basket",
        titleEnglish: "Fruits Basket",
        titleJapanese: "フルーツバスケット",
        score: 8.43,
        chapters: 136,
        startDate: "1998-07-01T00:00:00Z",
        endDate: "2006-11-20T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/2/35018.jpg"),
        synopsis: "After the accident in which she lost her mother, 16-year-old Tooru moves in with her grandfather, but due to his home being renovated, is unable to continue living with him. Claiming she will find someone to stay with but also fearing the criticism of her family and not wanting to burden any of her friends, Tooru resorts to secretly living on her own in a tent in the woods.",
        url: URL(string: "https://myanimelist.net/manga/120/Fruits_Basket"),
        volumes: 23,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440060")!, theme: "Romantic Subtext")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440061")!, firstName: "Natsuki", lastName: "Takaya", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440062")!, genre: "Drama"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440063")!, genre: "Romance"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440064")!, genre: "Supernatural")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440065")!, demographic: "Shoujo")
        ]
    )
    
    /// Vagabond - Drama histórico samurái
    @MainActor static let vagabond = Manga(
        id: 656,
        status: "on_hiatus",
        background: "Vagabond is based on the novel Musashi by Eiji Yoshikawa. It has won numerous awards and is acclaimed for its breathtaking artwork and philosophical depth. The series has been on hiatus since 2015.",
        title: "Vagabond",
        titleEnglish: "Vagabond",
        titleJapanese: "バガボンド",
        score: 9.16,
        chapters: 327,
        startDate: "1998-09-03T00:00:00Z",
        endDate: "2015-05-21T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/1/259070.jpg"),
        synopsis: "In 16th-century Japan, Shinmen Takezou is a wild, rough young man, in both his appearance and his actions. His aggressive nature has won him the collective reproach and fear of his village, leading him and his best friend, Matahachi Honiden, to run away in search of something grander than provincial life. The pair enlist in the Toyotomi army, yearning for glory—but when the Toyotomi suffer a crushing defeat at the hands of the Tokugawa Clan at the Battle of Sekigahara, the friends barely make it out alive.",
        url: URL(string: "https://myanimelist.net/manga/656/Vagabond"),
        volumes: 37,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440070")!, theme: "Historical"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440071")!, theme: "Martial Arts"),
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440072")!, theme: "Samurai")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440073")!, firstName: "Takehiko", lastName: "Inoue", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440074")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440075")!, genre: "Adventure"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440076")!, genre: "Drama")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440077")!, demographic: "Seinen")
        ]
    )
    
    /// Spy x Family - Comedia de acción con espías
    @MainActor static let spyFamily = Manga(
        id: 119161,
        status: "currently_publishing",
        background: "Spy x Family has become a massive hit, winning multiple awards and quickly becoming one of the best-selling manga series. It successfully blends action, comedy, and heartwarming family dynamics.",
        title: "Spy x Family",
        titleEnglish: "Spy x Family",
        titleJapanese: "SPY×FAMILY",
        score: 8.74,
        chapters: 95,
        startDate: "2019-03-25T00:00:00Z",
        endDate: "2024-12-12T00:00:00Z",
        mainPicture: URL(string: "https://cdn.myanimelist.net/images/manga/3/258245.jpg"),
        synopsis: "For the agent known as Twilight, no order is too tall if it is for the sake of peace. Operating as Westalis' master spy, Twilight works tirelessly to prevent extremists from sparking a war with neighboring country Ostania. For his latest mission, he must investigate Ostanian politician Donovan Desmond by infiltrating his son's school: the prestigious Eden Academy. Thus, the agent faces the most difficult task of his career: get married, have a child, and play family.",
        url: URL(string: "https://myanimelist.net/manga/119161/Spy_x_Family"),
        volumes: 14,
        themes: [
            Theme(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440080")!, theme: "Childcare")
        ],
        authors: [
            Author(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440081")!, firstName: "Tatsuya", lastName: "Endou", role: "Story & Art")
        ],
        genres: [
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440082")!, genre: "Action"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440083")!, genre: "Comedy"),
            Genre(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440084")!, genre: "Supernatural")
        ],
        demographics: [
            Demographic(id: UUID(uuidString: "550E8400-E29B-41D4-A716-446655440085")!, demographic: "Shounen")
        ]
    )
    
    /// Lista completa de mangas de prueba
    @MainActor static let sampleMangas: [Manga] = [
        naruto,
        deathNote,
        attackOnTitan,
        berserk,
        fullmetalAlchemist,
        fruitsBasket,
        vagabond,
        spyFamily
    ]
}
