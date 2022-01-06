import ComposableArchitecture
import SwiftHelpers
import SwiftUI
import SwiftUIHelpers
import WaniKani

struct LevelProgressionBar: View {
    struct ViewState: Equatable {
        struct UserLevel: Equatable {
            var current: Int
            var max: Int
        }

        struct AssignmentsProgress: Equatable {
            var passed: Int
            var total: Int
        }

        var userLevel: UserLevel
        var radicals: AssignmentsProgress
        var kanji: AssignmentsProgress

        init(
            state: HomeState
        ) {
            let level = state.user.level
            let maxLevel = state.user.subscription.maxLevelGranted
            userLevel = UserLevel(current: level, max: maxLevel)

            let assignmentsBySubject = Dictionary(
                grouping: state.assignments,
                by: \.subjectType
            )

            let radicalAssignments = assignmentsBySubject[.radical] ?? []
            let kanjiAssignments = assignmentsBySubject[.kanji] ?? []

            let passedRadicals = radicalAssignments.count(where: { $0.passed != nil })
            let passedKanji = kanjiAssignments.count(where: { $0.passed != nil })

            radicals = AssignmentsProgress(
                passed: min(passedRadicals, radicalAssignments.count),
                total: radicalAssignments.count
            )
            kanji = AssignmentsProgress(
                passed: min(passedKanji, Int(Double(kanjiAssignments.count) * 0.9)),
                total: kanjiAssignments.count
            )
        }
    }

    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store.scope(state: ViewState.init)) { viewStore in
            VStack(alignment: .trailing, spacing: 5) {
                ProgressView(
                    value: Double(viewStore.kanji.passed),
                    total: Double(viewStore.kanji.total)
                ) {
                    Text(levelProgressLabel(for: viewStore.state))
                        .font(.caption)
                }
                .progressViewStyle(ColorfulProgressViewStyle(accentColor: Color.kanji))
                .frame(height: 27)

                if let radicalsRemainingLabel = radicalsRemainingLabel(for: viewStore.state) {
                    Text(radicalsRemainingLabel)
                        .font(.caption)
                }
            }
        }
    }

    private func levelProgressLabel(for state: ViewState) -> String {
        let remaining = state.kanji.total - state.kanji.passed

        guard remaining > 0 else {
            return "You've passed all the kanji for this level"
        }

        let nextLevelMessage: String

        if state.userLevel.current < state.userLevel.max {
            nextLevelMessage = "to get to level \(state.userLevel.current + 1)"
        } else {
            nextLevelMessage = "to get to the end"
        }

        return "Pass \(remaining) more kanji \(nextLevelMessage)"
    }

    private func radicalsRemainingLabel(for state: ViewState) -> String? {
        let remaining = state.radicals.total - state.radicals.passed

        guard remaining > 0 else {
            return nil
        }

        return "Pass \(remaining) more radicals to unlock more kanji"
    }
}

struct LevelProgressionBar_Previews: PreviewProvider {
    static var previews: some View {
        LevelProgressionBar(
            store: Store(
                initialState: .init(user: .testing),
                reducer: homeReducer,
                environment: .init(
                    wanikaniClient: .init(),
                    subjects: .testing,
                    mainQueue: .main
                )
            )
        )
    }
}
