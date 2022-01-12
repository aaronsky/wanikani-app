import ComposableArchitecture
import SwiftUI
import WaniKani

public struct SubjectState: Equatable {
    public var subject: Subject
}

public enum SubjectAction: Equatable {

}

public struct SubjectEnvironment {

}

public let subjectReducer = Reducer<SubjectState, SubjectAction, SubjectEnvironment> { state, action, environment in
    return .none
}

public struct SubjectView: View {
    let store: Store<SubjectState, SubjectAction>

    public init(
        store: Store<SubjectState, SubjectAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Subject")
            }
        }
    }
}

struct SubjectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubjectView(
                store: .init(
                    initialState: .init(
                        subject: .kanji(.testing)
                    ),
                    reducer: subjectReducer,
                    environment: .init()
                )
            )
        }
    }
}
