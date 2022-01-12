import ComposableArchitecture
import WaniKani

extension WaniKaniComposableClient {
    public static let testing = Self(
        setToken: { _ in .none },
        listAssignments: { _, _ in .none },
        getAssignment: { _ in .none },
        startAssignment: { _ in .none },
        listLevelProgressions: { _, _ in .none },
        getLevelProgression: { _ in .none },
        listResets: { _, _ in .none },
        getReset: { _ in .none },
        listReviews: { _, _ in .none },
        getReview: { _ in .none },
        createReview: { _ in .none },
        listReviewStatistics: { _, _ in .none },
        getReviewStatistic: { _ in .none },
        listSpacedRepetitionSystems: { _, _ in .none },
        getSpacedRepetitionSystem: { _ in .none },
        listStudyMaterials: { _, _ in .none },
        getStudyMaterial: { _ in .none },
        createStudyMaterial: { _, _ in .none },
        updateStudyMaterial: { _ in .none },
        listSubjects: { _, _ in .none },
        getSubject: { _ in .none },
        summary: { .none },
        me: { .none },
        updateUser: { _ in .none },
        listVoiceActors: { _, _ in .none },
        getVoiceActor: { _ in .none }
    )
}
