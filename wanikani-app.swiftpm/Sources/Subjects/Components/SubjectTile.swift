import SwiftUI
import WaniKaniHelpers

public struct SubjectTile: View {
    var subject: Subject

    @ViewBuilder
    public var body: some View {
        switch subject {
        case .radical(let radical):
            if let characters = radical.characters {
                textTile(characters: characters, kind: .radical)
            } else if let image = radical.characterImages.first(where: { $0.contentType == "image/png" }) {
                imageTile(image: image, kind: .radical)
            }
        case .kanji(let kanji):
            textTile(characters: kanji.characters, kind: .kanji)
        case .vocabulary(let vocabulary):
            textTile(characters: vocabulary.characters, kind: .vocabulary)
        }
    }

    @ViewBuilder func textTile(characters: String, kind: Subject.Kind) -> some View {
        Text(characters)
            .padding(5)
            .background(kind.color)
            .shadow(radius: 1, y: 1)
    }

    @ViewBuilder func imageTile(image: Radical.CharacterImage, kind: Subject.Kind) -> some View {
        switch image.metadata {
        case .svg:
            fatalError("svg not supported at present")
        case .png(let png):
            AsyncImage(
                url: image.url,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: CGFloat(png.dimensions.width), maxHeight: CGFloat(png.dimensions.height))
                },
                placeholder: {
                    ProgressView()
                }
            )
            .padding(5)
            .background(kind.color)
            // .foregroundColor(png.color)
            .shadow(radius: 1, y: 1)
        }
    }
}

public struct SubjectTileGrid: View {
    public var columns: [GridItem]
    public var subjects: [Subject]
    public var limit: Int?

    public init(
        columns: [GridItem],
        subjects: [Subject],
        limit: Int? = nil
    ) {
        self.columns = columns
        self.subjects = subjects
        self.limit = limit
    }

    var nextSubjects: (subjects: ArraySlice<Subject>, showMoreTile: Bool) {
        if let limit = limit {
            guard limit < subjects.count else {
                return (subjects.prefix(limit), false)
            }
            return (subjects.prefix(limit - 1), true)
        }

        return (subjects[...], false)
    }

    public var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            let (subjects, showMoreTile) = nextSubjects
            ForEach(subjects) { subject in
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
                .padding(5)
                .background(Color(.systemGray3))
                .shadow(radius: 1, y: 1)
        }
    }
}

extension Subject.Kind {
    var color: Color {
        switch self {
        case .radical:
            return .radical
        case .kanji:
            return .kanji
        case .vocabulary:
            return .vocabulary
        }
    }
}

struct SubjectTile_Previews: PreviewProvider {
    static var previews: some View {
        SubjectTile(subject: .radical(.testing))
        SubjectTile(subject: .kanji(.testing))
        SubjectTile(subject: .vocabulary(.testing))
    }
}

struct SubjectTileGrid_Previews: PreviewProvider {
    static let columns: [GridItem] = []
    static var previews: some View {
        SubjectTileGrid(
            columns: columns,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
                .radical(.testing),
            ]
        )
        SubjectTileGrid(
            columns: columns,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
                .radical(.testing),
                .kanji(.testing),
            ],
            limit: 5
        )
        SubjectTileGrid(
            columns: columns,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
                .radical(.testing),
                .kanji(.testing),
            ],
            limit: 4
        )
    }
}
