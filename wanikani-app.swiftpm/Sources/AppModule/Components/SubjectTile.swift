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
    }

    @ViewBuilder
    func imageTile(url: URL, kind: Subject.Kind) -> some View {
        AsyncImage(url: url)
            .padding(4)
            .background(kind.color)
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
