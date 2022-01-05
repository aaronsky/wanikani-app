import CasePaths
import Subjects
import SwiftUI
import WaniKani

struct LessonsReviewsCard: View {
    enum Kind {
        case lessons
        case reviews
    }

    struct ViewState: Equatable {

    }

    let columns = Array(repeating: GridItem(.adaptive(minimum: 40)), count: 4)

    var kind: Kind
    //    var summary: Summary?
    //    let subjects: SubjectRepository
    //    var showUpcoming: Bool = false
    //
    //    var subjectIDs: [Subject.ID] {
    //        switch kind {
    //        case .lessons:
    //            return summary?
    //                .lessons
    //                .flatMap(\.subjectIDs) ?? []
    //        case .reviews:
    //            return summary?
    //                .reviews
    //                .filter { $0.available.timeIntervalSinceNow < 0 }
    //                .flatMap(\.subjectIDs) ?? []
    //        }
    //    }
    //
    //    var radicals: [Radical] {
    //        subjectIDs
    //            .lazy
    //            .compactMap { subjects[$0] }
    //            .compactMap(/Subject.radical)
    //    }
    //
    //    var kanji: [Kanji] {
    //        subjectIDs
    //            .lazy
    //            .compactMap { subjects[$0] }
    //            .compactMap(/Subject.kanji)
    //    }
    //
    //    var vocabulary: [Vocabulary] {
    //        subjectIDs
    //            .lazy
    //            .compactMap { subjects[$0] }
    //            .compactMap(/Subject.vocabulary)
    //    }
    //
    //    var nextLessons: [Subject] {
    //        subjectIDs
    //            .prefix(8)
    //            .compactMap { subjects[$0] }
    //    }

    var body: some View {
        Text("hello")
        //        HStack {
        //            VStack(alignment: .leading) {
        //                Text("\(subjectIDs.count) in the queue")
        //                    .font(.subheadline.bold())
        //                Spacer()
        //                if showUpcoming {
        //                    Text("Here's what's coming up next:")
        //                        .font(.caption)
        //                    SubjectTileGrid(columns: columns, subjects: nextLessons)
        //                }
        //            }
        //            Spacer()
        //            VStack(alignment: .trailing) {
        //                Text("\(radicals.count) radicals")
        //                    .foregroundColor(Color.radical)
        //                Text("\(kanji.count) kanji")
        //                    .foregroundColor(Color.kanji)
        //                Text("\(vocabulary.count) vocabulary")
        //                    .foregroundColor(Color.vocabulary)
        //                Spacer()
        //            }
        //        }
        //        .padding()
        //        .background(
        //            RoundedRectangle(cornerRadius: 10)
        //                .fill(Color(.systemGray5))
        //        )
    }
}
