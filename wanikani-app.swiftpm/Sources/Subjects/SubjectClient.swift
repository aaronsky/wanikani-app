import ComposableArchitecture
import SwiftUI
import WaniKani
import WaniKaniHelpers

public typealias SubjectsLookup = [Subject.ID: Subject]

public struct SubjectsLoadRequest {
    public var url: URL
}

public struct SubjectsSaveRequest {
    public var subjects: SubjectsLookup
    public var url: URL
}

public struct SubjectsLoadResponse: Equatable {
    public var subjects: SubjectsLookup
    public var lastModified: Date?
}

public struct SubjectClient {
    public var load: (SubjectsLoadRequest) -> Effect<SubjectsLoadResponse, Error>
    public var save: (SubjectsSaveRequest) -> Effect<Void, Error>

    public init(
        load: @escaping (SubjectsLoadRequest) -> Effect<SubjectsLoadResponse, Error>,
        save: @escaping (SubjectsSaveRequest) -> Effect<Void, Error>
    ) {
        self.load = load
        self.save = save
    }
}

func fetchSubjectsIfNeeded(
    subjects: SubjectsLookup,
    lastModified: Date? = nil,
    wanikani: WaniKani
) -> Effect<SubjectsLoadResponse, Error> {
    if let lastModified = lastModified, lastModified.timeIntervalSinceNow <= 21600 {
        return .none
    }

    return wanikani.allPages(.subjects(updatedAfter: lastModified))
        .reduce(subjects) { acc, responses in
            acc.merging(
                Dictionary(
                    responses.flatMap { $0.data.map { ($0.id, $0) } },
                    uniquingKeysWith: { (_, new) in new }
                ),
                uniquingKeysWith: { (_, new) in new }
            )
        }
        .map {
            SubjectsLoadResponse(subjects: $0, lastModified: Date())
        }
        .eraseToEffect()
}
