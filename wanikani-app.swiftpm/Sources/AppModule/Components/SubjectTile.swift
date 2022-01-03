import SwiftUI
import WaniKani

struct SubjectTile: View {
    var subject: Subject

    @ViewBuilder
    var body: some View {
        switch subject {
        case .radical(let radical):
            if let characters = radical.characters {
                textTile(characters: characters, kind: .radical)
            } else {
                imageTile(url: radical.characterImages.first!.url, kind: .radical)
            }
        case .kanji(let kanji):
            textTile(characters: kanji.characters!, kind: .kanji)
        case .vocabulary(let vocabulary):
            textTile(characters: vocabulary.characters!, kind: .vocabulary)
        }
    }

    @ViewBuilder
    func textTile(characters: String, kind: Subject.Kind) -> some View {
        Text(characters)
            .padding(4)
            .background(kind.color)
            .shadow(radius: 3, y: 1)
    }

    @ViewBuilder
    func imageTile(url: URL, kind: Subject.Kind) -> some View {
        AsyncImage(url: url)
            .padding(4)
            .background(kind.color)
            .shadow(radius: 3, y: 1)
    }
}

struct SubjectTileGrid: View {
    var columns: [GridItem]
    var subjects: [Subject]
    var limit: Int?

    var nextSubjects: (subjects: ArraySlice<Subject>, showMoreTile: Bool) {
        if let limit = limit {
            if limit < subjects.count {
                return (subjects.prefix(limit - 1), true)
            } else {
                return (subjects.prefix(limit), false)
            }
        }

        return (subjects[...], false)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            let (subjects, showMoreTile) = nextSubjects
            ForEach(subjects, id: \.self) { subject in
                SubjectTile(subject: subject)
            }
            if showMoreTile {
                OverflowTile()
            }
        }
    }

    struct OverflowTile: View {
        var body: some View {
            Text("...")
                .padding(4)
                .background(Color(.systemGray3))
                .shadow(radius: 3, y: 1)
        }
    }
}

extension Subject.Kind {
    var color: Color {
        switch self {
        case .radical:
            return Color("Radical")
        case .kanji:
            return Color("Kanji")
        case .vocabulary:
            return Color("Vocabulary")
        }
    }
}
