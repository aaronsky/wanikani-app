import ComposableArchitecture

#if DEBUG
    extension SubjectClient {
        public static let testing = Self(
            get: { _ in .none },
            update: { _ in .none },
            save: .none
        )
    }
#endif
