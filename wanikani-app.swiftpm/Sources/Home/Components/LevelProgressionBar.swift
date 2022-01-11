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
            user: User,
            assignments: [Assignment]
        ) {
            let level = user.level
            let maxLevel = user.subscription.maxLevelGranted
            userLevel = UserLevel(current: level, max: maxLevel)

            let assignmentsBySubject = Dictionary(
                grouping: assignments,
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

    let state: ViewState

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            ProgressView(
                value: Double(state.kanji.passed),
                total: Double(state.kanji.total)
            ) {
                Text(levelProgressLabel)
                    .font(.caption)
            }
            .progressViewStyle(ColorfulProgressViewStyle(accentColor: Color.kanji))
            .frame(height: 27)

            if let radicalsRemainingLabel = radicalsRemainingLabel {
                Text(radicalsRemainingLabel)
                    .font(.caption)
            }
        }
    }

    private var levelProgressLabel: String {
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

    private var radicalsRemainingLabel: String? {
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
            state: .init(
                user: .testing,
                assignments: []
            )
        )
    }
}
