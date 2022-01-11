import ComposableArchitecture
import WaniKani

extension WaniKaniComposableClient {
    public static let live: Self = {
        let client = LiveClient()

        return Self(
            authorize: { token in
                let oldValue = client.token
                client.token = token

                return client.send(.me)
            },
            listAssignments: client.send,
            getAssignment: client.send,
            startAssignment: client.send,
            listLevelProgressions: client.send,
            getLevelProgression: client.send,
            listResets: client.send,
            getReset: client.send,
            listReviews: client.send,
            getReview: client.send,
            createReview: client.send,
            listReviewStatistics: client.send,
            getReviewStatistic: client.send,
            listSpacedRepetitionSystems: client.send,
            getSpacedRepetitionSystem: client.send,
            listStudyMaterials: client.send,
            getStudyMaterial: client.send,
            createStudyMaterial: client.send,
            updateStudyMaterial: client.send,
            listSubjects: client.send,
            getSubject: client.send,
            summary: { client.send(.summary) },
            me: { client.send(.me) },
            updateUser: client.send,
            listVoiceActors: client.send,
            getVoiceActor: client.send
        )
    }()

    private class LiveClient {
        var client = WaniKani(configuration: .default, transport: URLSession.shared)

        var token: String? {
            get {
                client.token
            }
            set {
                client.token = newValue
            }
        }

        /// Sends a resource to WaniKani and responds accordingly.
        ///
        /// - Parameter resource: The resource object, which describes how to perform the request
        /// - Returns: the `Response` instance wrapped in an `Effect`
        func send<R>(_ resource: R) -> Effect<Response<R>.Content, Swift.Error>
        where R: Resource, R.Content: Decodable {
            Effect.task { [unowned self] in
                try await self.client.send(resource)
            }
            .map(\.data)
        }

        /// Sends a resource to WaniKani and responds accordingly.
        ///
        /// - Parameters:
        ///   - resource: The resource object, which describes how to perform the request
        ///   - pageOptions: Options for pagination, which are ignored by resources that do not involve pagination.
        /// - Returns: the `Response` instance wrapped in an `Effect`
        func send<R>(_ resource: R, pageOptions: PageOptions?) -> Effect<Response<R>.Content, Swift.Error>
        where R: Resource, R.Content: Decodable {
            Effect.task { [unowned self] in
                try await self.client.send(resource, pageOptions: pageOptions)
            }
            .map(\.data)
        }

        /// Sends a resource carrying a body to WaniKani and responds accordingly.
        ///
        /// - Parameter resource: The resource object, which describes how to perform the request.
        /// - Returns: the `Response` instance wrapped in an `Effect`
        func send<R>(_ resource: R) -> Effect<Response<R>.Content, Swift.Error>
        where R: Resource, R.Body: Encodable, R.Content: Decodable {
            Effect.task { [unowned self] in
                try await self.client.send(resource)
            }
            .map(\.data)
        }
    }
}
