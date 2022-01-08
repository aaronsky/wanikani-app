import ComposableArchitecture
import WaniKaniHelpers

public struct SubjectClient {
    public var get: (Subject.ID) -> Effect<Subject?, Error>
    public var update: (WaniKani) -> Effect<Void, Error>
    public var save: Effect<Void, Error>

    public init(
        get: @escaping (Subject.ID) -> Effect<Subject?, Error>,
        update: @escaping (WaniKani) -> Effect<Void, Error>,
        save: Effect<Void, Error>
    ) {
        self.get = get
        self.update = update
        self.save = save
    }
}
