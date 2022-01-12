import ComposableArchitecture
import SwiftUI
import WaniKani

public struct SubjectsState: Equatable {
    var query: String = ""

    public init() {

    }
}

public enum SubjectsAction: Equatable {
    case queryChanged(String)
}

public struct SubjectsEnvironment {
    public init() {

    }
}

public let subjectsReducer = Reducer<SubjectsState, SubjectsAction, SubjectsEnvironment> { state, action, environment in
    switch action {
    case .queryChanged(let query):
        return .none
    }
}

public struct SubjectsView: View {
    let store: Store<SubjectsState, SubjectsAction>

    public init(
        store: Store<SubjectsState, SubjectsAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Text(viewStore.query)
                Text("Subjects")
                Text("Subjects")
                Text("Subjects")
                Text("Subjects")
                Text("Subjects")
                Text("Subjects")
            }
            .searchable(
                text: viewStore.binding(
                    get: \.query,
                    send: SubjectsAction.queryChanged
                )
            )
            .navigationTitle("Subjects")
        }
    }
}

struct SubjecstView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubjectsView(
                store: .init(
                    initialState: .init(),
                    reducer: subjectsReducer,
                    environment: .init()
                )
            )
        }
    }
}
