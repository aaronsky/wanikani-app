import Combine
import ComposableArchitecture
import WaniKani

public struct WaniKaniComposableClient {
    // MARK: Authorization
    public var setToken: (String?) -> Effect<Void, Never>

    // MARK: Endpoints
    public var listAssignments: (Assignments.List, PageOptions?) -> Effect<Assignments.List.Content, Error>
    public var getAssignment: (Assignments.Get) -> Effect<Assignments.Get.Content, Error>
    public var startAssignment: (Assignments.Start) -> Effect<Assignments.Start.Content, Error>
    public var listLevelProgressions:
        (LevelProgressions.List, PageOptions?) -> Effect<LevelProgressions.List.Content, Error>
    public var getLevelProgression: (LevelProgressions.Get) -> Effect<LevelProgressions.Get.Content, Error>
    public var listResets: (Resets.List, PageOptions?) -> Effect<Resets.List.Content, Error>
    public var getReset: (Resets.Get) -> Effect<Resets.Get.Content, Error>
    public var listReviews: (Reviews.List, PageOptions?) -> Effect<Reviews.List.Content, Error>
    public var getReview: (Reviews.Get) -> Effect<Reviews.Get.Content, Error>
    public var createReview: (Reviews.Create) -> Effect<Reviews.Create.Content, Error>
    public var listReviewStatistics:
        (ReviewStatistics.List, PageOptions?) -> Effect<ReviewStatistics.List.Content, Error>
    public var getReviewStatistic: (ReviewStatistics.Get) -> Effect<ReviewStatistics.Get.Content, Error>
    public var listSpacedRepetitionSystems:
        (SpacedRepetitionSystems.List, PageOptions?) -> Effect<SpacedRepetitionSystems.List.Content, Error>
    public var getSpacedRepetitionSystem:
        (SpacedRepetitionSystems.Get) -> Effect<SpacedRepetitionSystems.Get.Content, Error>
    public var listStudyMaterials: (StudyMaterials.List, PageOptions?) -> Effect<StudyMaterials.List.Content, Error>
    public var getStudyMaterial: (StudyMaterials.Get) -> Effect<StudyMaterials.Get.Content, Error>
    public var createStudyMaterial: (StudyMaterials.List, PageOptions?) -> Effect<StudyMaterials.List.Content, Error>
    public var updateStudyMaterial: (StudyMaterials.Get) -> Effect<StudyMaterials.Get.Content, Error>
    public var listSubjects: (Subjects.List, PageOptions?) -> Effect<Subjects.List.Content, Error>
    public var getSubject: (Subjects.Get) -> Effect<Subjects.Get.Content, Error>
    public var summary: () -> Effect<Summaries.Get.Content, Error>
    public var me: () -> Effect<Users.Me.Content, Error>
    public var updateUser: (Users.Update) -> Effect<Users.Update.Content, Error>
    public var listVoiceActors: (VoiceActors.List, PageOptions?) -> Effect<VoiceActors.List.Content, Error>
    public var getVoiceActor: (VoiceActors.Get) -> Effect<VoiceActors.Get.Content, Error>

    // MARK: Initializer
    public init(
        setToken: @escaping (String?) -> Effect<Void, Never>,
        listAssignments: @escaping (Assignments.List, PageOptions?) -> Effect<Assignments.List.Content, Error>,
        getAssignment: @escaping (Assignments.Get) -> Effect<Assignments.Get.Content, Error>,
        startAssignment: @escaping (Assignments.Start) -> Effect<Assignments.Start.Content, Error>,
        listLevelProgressions: @escaping (LevelProgressions.List, PageOptions?) -> Effect<
            LevelProgressions.List.Content, Error
        >,
        getLevelProgression: @escaping (LevelProgressions.Get) -> Effect<LevelProgressions.Get.Content, Error>,
        listResets: @escaping (Resets.List, PageOptions?) -> Effect<Resets.List.Content, Error>,
        getReset: @escaping (Resets.Get) -> Effect<Resets.Get.Content, Error>,
        listReviews: @escaping (Reviews.List, PageOptions?) -> Effect<Reviews.List.Content, Error>,
        getReview: @escaping (Reviews.Get) -> Effect<Reviews.Get.Content, Error>,
        createReview: @escaping (Reviews.Create) -> Effect<Reviews.Create.Content, Error>,
        listReviewStatistics: @escaping (ReviewStatistics.List, PageOptions?) -> Effect<
            ReviewStatistics.List.Content, Error
        >,
        getReviewStatistic: @escaping (ReviewStatistics.Get) -> Effect<ReviewStatistics.Get.Content, Error>,
        listSpacedRepetitionSystems: @escaping (SpacedRepetitionSystems.List, PageOptions?) -> Effect<
            SpacedRepetitionSystems.List.Content, Error
        >,
        getSpacedRepetitionSystem: @escaping (SpacedRepetitionSystems.Get) -> Effect<
            SpacedRepetitionSystems.Get.Content, Error
        >,
        listStudyMaterials: @escaping (StudyMaterials.List, PageOptions?) -> Effect<StudyMaterials.List.Content, Error>,
        getStudyMaterial: @escaping (StudyMaterials.Get) -> Effect<StudyMaterials.Get.Content, Error>,
        createStudyMaterial: @escaping (StudyMaterials.List, PageOptions?) -> Effect<
            StudyMaterials.List.Content, Error
        >,
        updateStudyMaterial: @escaping (StudyMaterials.Get) -> Effect<StudyMaterials.Get.Content, Error>,
        listSubjects: @escaping (Subjects.List, PageOptions?) -> Effect<Subjects.List.Content, Error>,
        getSubject: @escaping (Subjects.Get) -> Effect<Subjects.Get.Content, Error>,
        summary: @escaping () -> Effect<Summaries.Get.Content, Error>,
        me: @escaping () -> Effect<Users.Me.Content, Error>,
        updateUser: @escaping (Users.Update) -> Effect<Users.Update.Content, Error>,
        listVoiceActors: @escaping (VoiceActors.List, PageOptions?) -> Effect<VoiceActors.List.Content, Error>,
        getVoiceActor: @escaping (VoiceActors.Get) -> Effect<VoiceActors.Get.Content, Error>
    ) {
        self.setToken = setToken
        self.listAssignments = listAssignments
        self.getAssignment = getAssignment
        self.startAssignment = startAssignment
        self.listLevelProgressions = listLevelProgressions
        self.getLevelProgression = getLevelProgression
        self.listResets = listResets
        self.getReset = getReset
        self.listReviews = listReviews
        self.getReview = getReview
        self.createReview = createReview
        self.listReviewStatistics = listReviewStatistics
        self.getReviewStatistic = getReviewStatistic
        self.listSpacedRepetitionSystems = listSpacedRepetitionSystems
        self.getSpacedRepetitionSystem = getSpacedRepetitionSystem
        self.listStudyMaterials = listStudyMaterials
        self.getStudyMaterial = getStudyMaterial
        self.createStudyMaterial = createStudyMaterial
        self.updateStudyMaterial = updateStudyMaterial
        self.listSubjects = listSubjects
        self.getSubject = getSubject
        self.summary = summary
        self.me = me
        self.updateUser = updateUser
        self.listVoiceActors = listVoiceActors
        self.getVoiceActor = getVoiceActor
    }

    public func paginate<R: Resource, Inner>(
        _ handler: @escaping (R, PageOptions?) -> Effect<R.Content, Error>,
        resource: R,
        startingFrom initialPageOptions: PageOptions? = nil
    ) -> Effect<R.Content, Error> where R.Content == ModelCollection<Inner> {
        let pageOptionsPublisher = CurrentValueSubject<PageOptions?, Error>(initialPageOptions)

        return
            pageOptionsPublisher
            .flatMap {
                handler(resource, $0)
            }
            .handleEvents(receiveOutput: {
                if let next = $0.page.next {
                    pageOptionsPublisher.send(next)
                } else {
                    pageOptionsPublisher.send(completion: .finished)
                }
            })
            .eraseToEffect()
    }
}
