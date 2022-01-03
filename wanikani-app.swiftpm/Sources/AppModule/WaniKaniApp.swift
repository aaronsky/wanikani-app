import SwiftUI

@main
struct WaniKaniApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var services = Services()
    @StateObject private var subjects = SubjectsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(services)
                .environmentObject(subjects)
                .task {
                    let (allSubjects, lastModified) = try! await SubjectsStore.loadPersistentStore(session: services.session)
                    subjects.subjects = allSubjects
                    subjects.lastModified = lastModified
                }
                .onChange(of: services.authState) { auth in
                    guard auth == .authenticated else {
                        return
                    }

                    Task.detached(priority: .background) {
                        try! await subjects.fetchSubjectsIfNeeded(services: services)
                    }
                }
                .onChange(of: scenePhase) { phase in
                    Task {
                        if phase == .inactive {
                            try! await SubjectsStore.savePersistentStore(subjects: subjects.subjects)
                        }
                    }
                }
        }
    }
}


