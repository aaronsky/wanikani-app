import ComposableArchitecture

#if DEBUG
    extension SubjectClient {
        public static let testing = Self(
            load: { _ in .none },
            save: { _ in .none }
        )
    }
#endif
