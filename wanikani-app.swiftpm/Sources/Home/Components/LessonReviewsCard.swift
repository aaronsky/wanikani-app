import CasePaths
import Subjects
import SwiftUI
import WaniKaniHelpers

struct LessonsReviewsCard: View {
    enum Kind {
        case lessons
        case reviews

        var color: Color {
            switch self {
            case .lessons:
                return Color.kanji
            case .reviews:
                return Color.radical
            }
        }
    }

    let columns = Array(repeating: GridItem(.adaptive(minimum: 40)), count: 4)

    let kind: Kind
    let subjects: SubjectGroups
    let showUpcoming: Bool

    init(
        kind: Kind,
        subjects: [Subject],
        showUpcoming: Bool = false
    ) {
        self.kind = kind
        self.subjects = SubjectGroups(subjects)
        self.showUpcoming = showUpcoming
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(subjects.count) in the queue")
                    .font(.subheadline.bold())
                Spacer()
                if showUpcoming {
                    Text("Here's what's coming up next:")
                        .font(.caption)
                    SubjectTileGrid(
                        columns: columns,
                        subjects: Array(subjects.prefix(8))
                    )
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(subjects.radicals.count) radicals")
                    .foregroundColor(.radical)
                Text("\(subjects.kanji.count) kanji")
                    .foregroundColor(.kanji)
                Text("\(subjects.vocabulary.count) vocabulary")
                    .foregroundColor(.vocabulary)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(kind.color)
                .colorMultiply(.white.opacity(0.75))
        )
    }
}

struct LessonsReviewsCard_Previews: PreviewProvider {
    static var previews: some View {
        LessonsReviewsCard(
            kind: .lessons,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
            ]
        )
        LessonsReviewsCard(
            kind: .lessons,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
            ],
            showUpcoming: true
        )
        LessonsReviewsCard(
            kind: .reviews,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
            ]
        )
        LessonsReviewsCard(
            kind: .reviews,
            subjects: [
                .radical(.testing),
                .kanji(.testing),
                .vocabulary(.testing),
            ],
            showUpcoming: true
        )
    }
}
