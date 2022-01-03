import SwiftUI
import WaniKani

enum ErrorCategory {
    case passive
    case requiresLogout
    case retryable
    case nonRetryable
}

protocol CategorizedError: Error {
    var category: ErrorCategory { get }
}

extension Error {
    var category: ErrorCategory {
        (self as? CategorizedError)?.category ?? .nonRetryable
    }
}

extension WaniKani.Error: CategorizedError {
    var category: ErrorCategory {
        switch self.statusCode {
        case .ok, .notModified:
            return .passive
        case .unauthorized, .forbidden:
            return .requiresLogout
        case .notFound, .tooManyRequests, .internalServerError, .serviceUnavailable:
            return .retryable
        case .unprocessableEntity:
            return .nonRetryable
        }
    }
}

protocol ErrorReporter {
    @MainActor
    func handle<T: View>(
        _ error: Error?,
        in view: T,
        services: Services,
        retryHandler: @escaping () async -> Void
    ) -> AnyView
}

struct AlertErrorReporter: ErrorReporter {
    private let id = UUID()

    func handle<T: View>(
        _ error: Error?,
        in view: T,
        services: Services,
        retryHandler: @escaping () async -> Void
    ) -> AnyView {
        guard let category = error?.category else {
            return AnyView(view)
        }

        guard category != .requiresLogout else {
            try? services.logout()
            return AnyView(view)
        }

        guard category != .passive else {
            return AnyView(view)
        }

        var presentation = error.map {
            Presentation(id: id,
                         error: $0,
                         retryHandler: retryHandler)
        }

        let binding = Binding(get: { presentation },
                              set: { presentation = $0 })

        return AnyView(view.alert(item: binding, content: makeAlert))
    }
}

private extension AlertErrorReporter {
    struct Presentation: Identifiable {
        let id: UUID
        let error: Error
        let retryHandler: () async -> Void
    }

    func makeAlert(for presentation: Presentation) -> Alert {
        let error = presentation.error

        switch error.category {
        case .passive, .requiresLogout:
            assertionFailure("no alerts for passive errors")
            return Alert(title: Text("An error occurred"))
        case .retryable:
            let retryButton: Alert.Button = .default(Text("Retry")) {
                Task {
                    await presentation.retryHandler()
                }
            }
            return Alert(title: Text("An error occured"),
                         message: Text(error.localizedDescription),
                         primaryButton: .default(Text("Dismiss")),
                         secondaryButton: retryButton)
        case .nonRetryable:
            return Alert(title: Text("An error occured"),
                         message: Text(error.localizedDescription),
                         dismissButton: .default(Text("Dismiss")))
        }
    }
}

struct ErrorReporterEnvironmentKey: EnvironmentKey {
    static var defaultValue: ErrorReporter = AlertErrorReporter()
}

extension EnvironmentValues {
    var errorReporter: ErrorReporter {
        get { self[ErrorReporterEnvironmentKey.self] }
        set { self[ErrorReporterEnvironmentKey.self] = newValue }
    }
}

struct ErrorEmittingViewModifier: ViewModifier {
    @Environment(\.errorReporter) private var handler
    @EnvironmentObject private var services: Services

    var error: Error?
    var retryHandler: () async -> Void

    func body(content: Content) -> some View {
        handler.handle(error,
                       in: content,
                       services: services,
                       retryHandler: retryHandler)
    }
}

extension View {
    func handlingErrors(
        using handler: ErrorReporter
    ) -> some View {
        environment(\.errorReporter, handler)
    }

    func handlingErrors(
        in error: Error?,
        onRetry: @escaping () async -> Void = {}
    ) -> some View {
        modifier(
            ErrorEmittingViewModifier(error: error,
                                      retryHandler: onRetry)
        )
    }

    func taskWithErrorHandling(
        error: Error?,
        priority: TaskPriority = .userInitiated,
        _ action: @Sendable @escaping () async -> Void
    ) -> some View {
        handlingErrors(in: error,
                       onRetry: action)
            .task(priority: priority,
                  action)
    }
}
