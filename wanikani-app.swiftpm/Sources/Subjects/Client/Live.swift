import ComposableArchitecture
import WaniKani

extension SubjectClient {
    public static func live(url: URL) -> Self {
        var _storage: InMemoryStorage!

        func storage() throws -> InMemoryStorage {
            if _storage == nil {
                _storage = try InMemoryStorage(url: url)
            }
            return _storage
        }

        return Self(
            get: { id in
                .catching { try storage().subjects[id] }
            },
            update: { wanikaniClient in
                .catching { try storage().update(from: wanikaniClient) }
            },
            save: .catching { try storage().save(to: url) }
        )
    }

    private class InMemoryStorage {
        var subjects: [Subject.ID: Subject] = [:]
        var lastModified: Date?

        init(
            url: URL
        ) throws {
            var modificationDate: Date?
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
                modificationDate = attrs[.modificationDate] as? Date
            }

            guard let data = try? Data(contentsOf: url),
                let subjects = try? JSONDecoder().decode([Subject.ID: Subject].self, from: data)
            else {
                self.subjects = [:]
                self.lastModified = nil
                return
            }

            self.subjects = subjects
            self.lastModified = modificationDate
        }

        func update(from wanikani: WaniKani) throws {
            if let lastModified = lastModified,
                lastModified.timeIntervalSinceNow <= 21600
            {
                return
            }

            Task {
                for try await response in wanikani.paginate(.subjects(updatedAfter: lastModified)) {
                    subjects.merge(
                        Dictionary(
                            response.data.map { ($0.id, $0) },
                            uniquingKeysWith: { (_, new) in new }
                        ),
                        uniquingKeysWith: { (_, new) in new }
                    )
                }
            }
        }

        func save(to url: URL) throws {
            let data = try JSONEncoder().encode(subjects)
            try data.write(to: url)
        }
    }
}
