import SwiftUI
import WaniKani

struct HomeView: View {
    @EnvironmentObject private var services: Services
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List {
            Section {
                if let nextReviews = viewModel.summary?.nextReviews {
                    Text("Your next review will be in \(nextReviews.formatted(.relative(presentation: .named)))")
                        .font(.subheadline.bold())
                }

                LevelProgressionBar(assignments: viewModel.assignments)
            }
            .listRowSeparator(.hidden)

            Text("Coming Up")
                .font(.title2.bold())
                .listRowSeparator(.hidden)

            Section(
                header: Text("Lessons")
                    .font(.title3.bold())
            ) {
                LessonsReviewsCard(kind: .lessons,
                                   summary: viewModel.summary,
                                   showUpcoming: true)
            }
            .listRowSeparator(.hidden)

            Section(
                header: Text("Reviews")
                    .font(.title3.bold())
            ) {
                LessonsReviewsCard(kind: .reviews,
                                   summary: viewModel.summary,
                                   showUpcoming: false)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("Welcome, \(services.user!.username)!")
        .toolbar(content: toolbar)
        .refreshable {
            await viewModel.fetchSummary(services: services)
            await viewModel.fetchAssignments(services: services)
        }
        .taskWithErrorHandling(error: viewModel.error) {
            await viewModel.fetchSummary(services: services)
            await viewModel.fetchAssignments(services: services)
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button(
                action: {
                    print("start review")
                },
                label: {
                    Label("Start Review", systemImage: "square.and.pencil")
                        .font(.body)
                        .labelStyle(.titleAndIcon)
                }
            )
            Spacer()
        }
    }
    
    @MainActor
    class ViewModel: ObservableObject {
        @Published var error: Error?

        @Published var summary: Summary?
        @Published var assignments: [Assignment] = []
        
        func fetchSummary(services: Services) async {
            do {
                let response = try await services.send(.summary)
                summary = response.data
            } catch {
                self.error = error
            }
        }

        func fetchAssignments(services: Services) async {
            do {
                let response = try await services.send(.assignments(levels: [services.user!.level]))
                assignments = Array(response.data)
            } catch {
                self.error = error
            }
        }
    }
}

struct LevelProgressionBar: View {
    @EnvironmentObject private var services: Services

    private var passedRadicalAssignments: Int
    private var passedKanjiAssignments: Int
    private var totalRadicalAssignments: Int
    private var totalKanjiAssignments: Int

    init(assignments: [Assignment]) {
        let assignmentsBySubject = Dictionary(grouping: assignments, by: \.subjectType)

        let radicals = assignmentsBySubject[.radical] ?? []
        let passedRadicals = radicals.filter { $0.passed != nil }
        totalRadicalAssignments = radicals.count
        passedRadicalAssignments = min(passedRadicals.count, totalRadicalAssignments)

        let kanji = assignmentsBySubject[.kanji] ?? []
        let passedKanji = kanji.filter { $0.passed != nil }
        totalKanjiAssignments = kanji.count
        passedKanjiAssignments = min(passedKanji.count, Int(Double(totalKanjiAssignments) * 0.9))
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            ProgressView(
                value: Double(passedKanjiAssignments),
                total: Double(totalKanjiAssignments)) {
                    Text(levelProgressLabel)
                        .font(.caption)
                }
                .progressViewStyle(ColorfulProgressViewStyle(accentColor: Color("Kanji")))
                .frame(height: 27)

            if let radicalsRemainingLabel = radicalsRemainingLabel {
                Text(radicalsRemainingLabel)
                    .font(.caption)
            }
        }
    }

    private var levelProgressLabel: String {
        let remaining = totalKanjiAssignments - passedKanjiAssignments

        if remaining > 0 {
            let nextLevelMessage: String

            if services.user!.level < services.user!.subscription.maxLevelGranted {
                nextLevelMessage = "to get to level \(services.user!.level + 1)"
            } else {
                nextLevelMessage = "to get to the end"
            }

            return "Pass \(remaining) more kanji \(nextLevelMessage)"
        } else {
            return "You've passed all the kanji for this level"
        }
    }

    private var radicalsRemainingLabel: String? {
        let remaining = totalRadicalAssignments - passedRadicalAssignments

        guard remaining > 0 else {
            return nil
        }

        return "Pass \(remaining) more radicals to unlock more kanji"
    }
}

struct LessonsReviewsCard: View {
    enum Kind {
        case lessons
        case reviews
    }

    @EnvironmentObject private var services: Services
    @EnvironmentObject private var subjects: SubjectsStore

    let rows = Array(repeating: GridItem(.fixed(40)), count: 4)

    var kind: Kind
    var summary: Summary?
    var showUpcoming: Bool = false

    var subjectIDs: [Subject.ID] {
        switch kind {
        case .lessons:
            return summary?.lessons.flatMap(\.subjectIDs) ?? []
        case .reviews:
            return summary?
                .reviews
                .filter { $0.available.timeIntervalSinceNow < 0 }
                .flatMap(\.subjectIDs) ?? []
        }
    }

    var radicals: [Radical] {
        subjectIDs
            .compactMap {
                guard case .radical(let radical) = subjects[$0] else {
                    return nil
                }

                return radical
            }
    }

    var kanji: [Kanji] {
        subjectIDs
            .compactMap {
                guard case .kanji(let kanji) = subjects[$0] else {
                    return nil
                }

                return kanji
            }
    }

    var vocabulary: [Vocabulary] {
        subjectIDs
            .compactMap {
                guard case .vocabulary(let vocabulary) = subjects[$0] else {
                    return nil
                }

                return vocabulary
            }
    }

    var nextTenLessons: [Subject] {
        subjectIDs
            .prefix(10)
            .compactMap { subjects[$0] }
    }

    var body: some View {
        HStack {
            VStack {
                Text("\(subjectIDs.count) in the queue")
                    .font(.subheadline.bold())
                Spacer()
                if showUpcoming {
                    LazyHGrid(rows: rows, spacing: 10) {
                        ForEach(nextTenLessons, id: \.self) { subject in
                            SubjectTile(subject: subject)
                        }
                    }
                }
            }
            Spacer()
            VStack {
                Text("\(radicals.count) radicals")
                    .foregroundColor(Color("Radical"))
                Text("\(kanji.count) kanji")
                    .foregroundColor(Color("Kanji"))
                Text("\(vocabulary.count) vocabulary")
                    .foregroundColor(Color("Vocabulary"))
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
        )
    }
}

