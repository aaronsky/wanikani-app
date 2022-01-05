import AppCore
import SwiftUI

private func subjectsDataFileURL(name: String = "subjects.data") throws -> URL {
    try FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(name)
}

@main struct WaniKaniApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(
                    initialState: .init(),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        wanikaniClient: .init(),
                        authenticationClient: .live,
                        subjects: .live(url: try! subjectsDataFileURL()),
                        mainQueue: .main
                    )
                )
            )
        }
    }
}

struct WaniKaniApp_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(),
                reducer: appReducer,
                environment: .init(
                    wanikaniClient: .init(),
                    authenticationClient: .testing,
                    subjects: .testing,
                    mainQueue: .main
                )
            )
        )
    }
}
