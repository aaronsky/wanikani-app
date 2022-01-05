import ComposableArchitecture
import WaniKani

extension SubjectClient {
    public static let live = Self(
        load: Self.loadFromDisk,
        save: Self.saveToDisk
    )

    //    private static func fileURL(name: String = "subjects.data") throws -> URL {
    //        try FileManager.default
    //            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    //            .appendingPathComponent(name)
    //    }

    private static func loadFromDisk(request: SubjectsLoadRequest) -> Effect<SubjectsLoadResponse, Error> {
        Effect.catching {
            var modificationDate: Date?
            if let attrs = try? FileManager.default.attributesOfItem(atPath: request.url.path) {
                modificationDate = attrs[.modificationDate] as? Date
            }

            guard let data = try? Data(contentsOf: request.url),
                let subjects = try? JSONDecoder().decode(SubjectsLookup.self, from: data)
            else {
                return SubjectsLoadResponse(subjects: [:], lastModified: nil)
            }

            return SubjectsLoadResponse(subjects: subjects, lastModified: modificationDate)

        }
    }

    private static func saveToDisk(request: SubjectsSaveRequest) -> Effect<Void, Error> {
        Effect.catching {
            let data = try JSONEncoder().encode(request.subjects)
            try data.write(to: request.url)
        }
    }
}
