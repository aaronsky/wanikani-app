import SwiftUI
import WaniKani

class SubjectsStore: ObservableObject {
    @Published var subjects: [Subject.ID: Subject] = [:]
    var lastModified: Date?
    
    subscript(id: Subject.ID) -> Subject? {
        subjects[id]
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("subjects.data")
    }
    
    static func loadPersistentStore(session: URLSession = .shared) async throws -> ([Subject.ID: Subject], Date?) {
        do {
            let url = try fileURL()

            var modificationDate: Date?
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
                modificationDate = attrs[.modificationDate] as? Date
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return ([:], nil)
            }
            
            let subjects = try JSONDecoder().decode([Subject.ID: Subject].self, from: data)
            
            return (subjects, modificationDate)
        } catch {
            throw error
        }
    }
    
    func fetchSubjectsIfNeeded(services: Services) async throws {
        guard lastModified == nil || lastModified!.timeIntervalSinceNow > 21600 else {
            return
        }

        var allSubjects = subjects
        var nextPage: PageOptions?

        repeat {
            do {
                let response = try await services.send(.subjects(updatedAfter: lastModified), pageOptions: nextPage)
                
                let subjectPairs = response.data.map { ($0.id, $0) }
                allSubjects.merge(Dictionary(subjectPairs,
                                             uniquingKeysWith: { (_, new) in new }),
                                  uniquingKeysWith: { (_, new) in new })
                
                nextPage = response.page.next
            } catch ResponseError.rateLimitExceeded(_, _, let rateReset) {
                try await Task.sleep(nanoseconds: UInt64(rateReset.timeIntervalSinceNow) * NSEC_PER_SEC)
            }
        } while nextPage != nil
        
        self.subjects = allSubjects
        self.lastModified = Date()
    }
    
    static func savePersistentStore(subjects: [Subject.ID: Subject]) async throws {
        let data = try JSONEncoder().encode(subjects)
        let url = try fileURL()
        try data.write(to: url)
    }
}
