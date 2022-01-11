import Foundation
import WaniKani

#if DEBUG
extension Radical {
    public static let testing = Self(
        amalgamationSubjectIDs: [
            440, 449, 450, 451, 468, 488, 531, 533, 568, 590, 609, 633, 635, 709, 710, 724, 783, 808, 885, 913, 932,
            965, 971, 1000, 1020, 1085, 1113, 1119, 1126, 1137, 1178, 1198, 1241, 1249, 1326, 1340, 1367, 1372,
            1376, 1379, 1428, 1431, 1463, 1491, 1506, 1521, 1547, 1559, 1591, 1655, 1769, 1851, 1852, 1855, 1868,
            1869, 1888, 1970, 2091, 2104, 2128, 2138, 2148, 2171, 2172, 2182, 2212, 2277, 2334, 2375, 2419, 2437,
        ],
        auxiliaryMeanings: [],
        characters: "一",
        characterImages: [
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/a7w32gazaor51ii0fbtxzk0wpmpc")!,
                metadata: .svg(.init(containsInlineStyles: false))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/fxufa23ht9uh0tkedo1zx5jemaio")!,
                metadata: .svg(.init(containsInlineStyles: true))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/4lxmimfbwuvl07s11dq0f9til0mb")!,
                metadata: .png(
                    .init(color: "#000000", dimensions: .init(width: 1024, height: 1024), styleName: "original")
                )
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/3n3dlzyjjgou47qb4h4uewghcfcx")!,
                metadata: .png(.init(color: "#000000", dimensions: .init(width: 512, height: 512), styleName: "512px"))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/gfwzjl41i5v5oiwrsjz5zz957nww")!,
                metadata: .png(.init(color: "#000000", dimensions: .init(width: 256, height: 256), styleName: "256px"))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/m79ver1yfujpkcfa0bo5tcueuxk3")!,
                metadata: .png(.init(color: "#000000", dimensions: .init(width: 128, height: 128), styleName: "128px"))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/gcqkjhbw9aguieat8yrqxz09qszn")!,
                metadata: .png(.init(color: "#000000", dimensions: .init(width: 64, height: 64), styleName: "64px"))
            ),
            CharacterImage(
                url: URL(string: "https://files.wanikani.com/7czfgjlgsjxx8sndvfkezts6ugj1")!,
                metadata: .png(.init(color: "#000000", dimensions: .init(width: 32, height: 32), styleName: "32px"))
            ),
        ],
        created: dateFormatter.date(from: "2012-02-27T18:08:16.000000Z")!,
        documentURL: URL(string: "https://www.wanikani.com/radicals/ground")!,
        hidden: nil,
        id: 1,
        lastUpdated: dateFormatter.date(from: "2021-12-27T18:21:59.471494Z")!,
        lessonPosition: 0,
        level: 1,
        meaningMnemonic:
            "This radical consists of a single, horizontal stroke. What's the biggest, single, horizontal stroke? That's the <radical>ground</radical>. Look at the ground, look at this radical, now look at the ground again. Kind of the same, right?",
        meanings: [
            Meaning(
                meaning: "Ground",
                isPrimary: true,
                isAcceptedAnswer: true
            )
        ],
        slug: "ground",
        spacedRepetitionSystemID: 2,
        url: URL(string: "https://api.wanikani.com/v2/subjects/1")!
    )
}

extension Kanji {
    public static let testing = Self(
        amalgamationSubjectIDs: [
            2467, 2468, 2477, 2510, 2544, 2588, 2627, 2660, 2665, 2672, 2679, 2721, 2730, 2751, 2959, 3048, 3256,
            3335, 3348, 3349, 3372, 3481, 3527, 3528, 3656, 3663, 4133, 4173, 4258, 4282, 4563, 4615, 4701, 4823,
            4906, 5050, 5224, 5237, 5349, 5362, 5838, 6010, 6029, 6150, 6169, 6209, 6210, 6346, 6584, 6614, 6723,
            6811, 6851, 7037, 7293, 7305, 7451, 7561, 7617, 7734, 7780, 7927, 8209, 8214, 8414, 8456, 8583, 8709,
            8896, 8921, 9056, 9103,
        ],
        auxiliaryMeanings: [
            .init(meaning: "1", type: .allowlist)
        ],
        characters: "一",
        componentSubjectIDs: [1],
        created: dateFormatter.date(from: "2012-02-27T19:55:19.000000Z")!,
        documentURL: URL(string: "https://www.wanikani.com/kanji/%E4%B8%80")!,
        hidden: nil,
        id: 440,
        lastUpdated: dateFormatter.date(from: "2021-11-04T18:12:11.194167Z")!,
        lessonPosition: 26,
        level: 1,
        meaningHint:
            "To remember the meaning of <kanji>One</kanji>, imagine yourself there at the scene of the crime. You grab <kanji>One</kanji> in your arms, trying to prop it up, trying to hear its last words. Instead, it just splatters some blood on your face. \"Who did this to you?\" you ask. The number One points weakly, and you see number Two running off into an alleyway. He's always been jealous of number One and knows he can be number one now that he's taken the real number one out.",
        meaningMnemonic:
            "Lying on the <radical>ground</radical> is something that looks just like the ground, the number <kanji>One</kanji>. Why is this One lying down? It's been shot by the number two. It's lying there, bleeding out and dying. The number One doesn't have long to live.",
        meanings: [
            .init(meaning: "One", isPrimary: true, isAcceptedAnswer: true)
        ],
        readingHint:
            "Make sure you feel the ridiculously <reading>itchy</reading> sensation covering your body. It climbs from your hands, where you're holding the number <kanji>One</kanji> up, and then goes through your arms, crawls up your neck, goes down your body, and then covers everything. It becomes uncontrollable, and you're scratching everywhere, writhing on the ground. It's so itchy that it's the most painful thing you've ever experienced (you should imagine this vividly, so you remember the reading of this kanji).",
        readingMnemonic:
            "As you're sitting there next to <kanji>One</kanji>, holding him up, you start feeling a weird sensation all over your skin. From the wound comes a fine powder (obviously coming from the special bullet used to kill One) that causes the person it touches to get extremely <reading>itchy</reading> (<ja>いち</ja>).",
        readings: [
            .init(reading: "いち", isPrimary: true, isAcceptedAnswer: true, type: .onyomi),
            .init(reading: "ひと", isPrimary: false, isAcceptedAnswer: false, type: .kunyomi),
            .init(reading: "かず", isPrimary: false, isAcceptedAnswer: false, type: .nanori),
            .init(reading: "いつ", isPrimary: true, isAcceptedAnswer: true, type: .onyomi),
        ],
        slug: "一",
        spacedRepetitionSystemID: 2,
        visuallySimilarSubjectIDs: [],
        url: URL(string: "https://api.wanikani.com/v2/subjects/440")!
    )
}

extension Vocabulary {
    public static let testing = Self(
        auxiliaryMeanings: [
            .init(meaning: "1", type: .allowlist)
        ],
        characters: "一",
        componentSubjectIDs: [440],
        contextSentences: [
            .init(english: "Let’s meet up once.", japanese: "一ど、あいましょう。"),
            .init(english: "First place was an American.", japanese: "一いはアメリカ人でした。"),
            .init(english: "I’m the weakest (person) in the world.", japanese: "ぼくはせかいで一ばんよわい。"),
        ],
        created: dateFormatter.date(from: "2012-02-28T08:04:47.000000Z")!,
        documentURL: URL(string: "https://www.wanikani.com/vocabulary/%E4%B8%80")!,
        hidden: nil,
        id: 2467,
        lastUpdated: dateFormatter.date(from: "2021-09-01T18:22:40.891504Z")!,
        lessonPosition: 44,
        level: 1,
        meaningMnemonic:
            "As is the case with most vocab words that consist of a single kanji, this vocab word has the same meaning as the kanji it parallels, which is <vocabulary>one</vocabulary>.",
        meanings: [
            .init(meaning: "One", isPrimary: true, isAcceptedAnswer: true)
        ],
        partsOfSpeech: [
            "numeral"
        ],
        pronunciationAudios: [
            .init(
                url: URL(string: "https://files.wanikani.com/aeevlg446own3mcs6rye6k4wfq37")!,
                contentType: "audio/ogg",
                metadata: .init(
                    gender: "female",
                    sourceID: 21630,
                    pronunciation: "いち",
                    voiceActorID: 1,
                    voiceActorName: "Kyoko",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/w6loj76y9t8ppripy1eindt5dg3y")!,
                contentType: "audio/webm",
                metadata: .init(
                    gender: "female",
                    sourceID: 21630,
                    pronunciation: "いち",
                    voiceActorID: 1,
                    voiceActorName: "Kyoko",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/j5dy9yyxpzsywaxifq1c7yc3ctal")!,
                contentType: "audio/webm",
                metadata: .init(
                    gender: "male",
                    sourceID: 2711,
                    pronunciation: "いち",
                    voiceActorID: 2,
                    voiceActorName: "Kenichi",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/tfdkyds03nhrbs6to3e0q4avbg1u")!,
                contentType: "audio/webm",
                metadata: .init(
                    gender: "male",
                    sourceID: 2711,
                    pronunciation: "いち",
                    voiceActorID: 2,
                    voiceActorName: "Kenichi",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/vtyum09bj9tf2gle7i4ip04iao6s")!,
                contentType: "audio/webm",
                metadata: .init(
                    gender: "female",
                    sourceID: 21630,
                    pronunciation: "いち",
                    voiceActorID: 1,
                    voiceActorName: "Kyoko",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/5g89i8489j2joklaqdoy89rzhlqf")!,
                contentType: "audio/ogg",
                metadata: .init(
                    gender: "male",
                    sourceID: 2711,
                    pronunciation: "いち",
                    voiceActorID: 2,
                    voiceActorName: "Kenichi",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/jkdnvm82i2kl6my5ts67idq2qdc6")!,
                contentType: "audio/mpeg",
                metadata: .init(
                    gender: "male",
                    sourceID: 2711,
                    pronunciation: "いち",
                    voiceActorID: 2,
                    voiceActorName: "Kenichi",
                    voiceDescription: "Tokyo accent"
                )
            ),
            .init(
                url: URL(string: "https://files.wanikani.com/dwikzn441ltuq4evi7bmt5g3v7q2")!,
                contentType: "audio/mpeg",
                metadata: .init(
                    gender: "female",
                    sourceID: 21630,
                    pronunciation: "いち",
                    voiceActorID: 1,
                    voiceActorName: "Kyoko",
                    voiceDescription: "Tokyo accent"
                )
            ),
        ],
        readings: [
            .init(reading: "いち", isPrimary: true, isAcceptedAnswer: true)
        ],
        readingMnemonic:
            "When a vocab word is all alone and has no okurigana (hiragana attached to kanji) connected to it, it usually uses the kun'yomi reading. Numbers are an exception, however. When a number is all alone, with no kanji or okurigana, it is going to be the on'yomi reading, which you learned with the kanji.  Just remember this exception for alone numbers and you'll be able to read future number-related vocab to come.",
        slug: "一",
        spacedRepetitionSystemID: 2,
        url: URL(string: "https://api.wanikani.com/v2/subjects/2467")!
    )
}
#endif
