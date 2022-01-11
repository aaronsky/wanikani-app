import Foundation
import WaniKani

#if DEBUG
extension User {
    public static let testing = Self(
        currentVacationStarted: nil,
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        lastUpdated: nil,
        level: 32,
        preferences: Preferences(
            autoplayLessonsAudio: false,
            autoplayReviewsAudio: false,
            defaultVoiceActorID: 1,
            displayReviewsSRSIndicator: true,
            lessonsBatchSize: 5,
            lessonsPresentationOrder: .ascendingLevelThenSubject
        ),
        profileURL: URL(string: "https://www.wanikani.com/users/metc")!,
        started: Date(timeIntervalSinceNow: -15_780_000),
        subscription: Subscription(
            isActive: true,
            maxLevelGranted: 60,
            periodEnds: nil,
            type: .lifetime
        ),
        username: "metc",
        url: URL(string: "https://api.wanikani.com/v2/user")!
    )
}
#endif
