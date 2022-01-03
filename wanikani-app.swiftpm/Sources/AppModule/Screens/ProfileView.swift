import SwiftUI
import WaniKani

struct ProfileView: View {
    @EnvironmentObject private var services: Services
    @StateObject private var viewModel = ViewModel()

    @State private var defaultVoiceActorID: Int = 0
    @State private var lessonsAutoplayAudio: Bool = false
    @State private var lessonsBatchSize: Int = 0
    @State private var lessonsPresentationOrder: User.Preferences.PresentationOrder = .ascendingLevelThenSubject
    @State private var reviewsAutoplayAudio: Bool = false
    @State private var reviewsDisplaySRSIndicator: Bool = false

    var vacationIndicator: String? {
        guard services.user?.currentVacationStarted != nil else {
            return nil
        }
        return "🌴"
    }

    var body: some View {
        NavigationView {
            Form {
                let user = services.user!
                Section {
                    Text("\(user.username) – Level \(user.level) \(vacationIndicator ?? "")")
                    Text("\(user.subscription.type.rawValue.capitalized) member since \(user.started.formatted(.dateTime.month().year()))")
                }
                Section {
                    Picker("Default voice actor", selection: $defaultVoiceActorID) {
                        ForEach(viewModel.voiceActors) { voiceActor in
                            Text("\(voiceActor.name) (\(voiceActor.description))")
                                .tag(voiceActor.id)
                        }
                    }.disabled(viewModel.voiceActors.isEmpty)
                }
                Section("Lessons") {
                    Toggle("Autoplay audio", isOn: $lessonsAutoplayAudio)
                    Picker("Batch size", selection: $lessonsBatchSize) {
                        ForEach(3...10, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                        }
                    }
                    Picker("Presentation order", selection: $lessonsPresentationOrder) {
                        Text("Ascending level, then subject")
                            .tag(User.Preferences.PresentationOrder.ascendingLevelThenSubject)
                        Text("Shuffled")
                            .tag(User.Preferences.PresentationOrder.shuffled)
                        Text("Ascending level, then shuffled")
                            .tag(User.Preferences.PresentationOrder.ascendingLevelThenShuffled)
                    }
                }
                Section("Reviews") {
                    Toggle("Autoplay audio", isOn: $reviewsAutoplayAudio)
                    Toggle("Display SRS indicator", isOn: $reviewsDisplaySRSIndicator)
                }
                Section {
                    Button("Save") {
                        Task {
                            await viewModel.updateUserPreferences(services: services,
                                                                  defaultVoiceActorID: defaultVoiceActorID,
                                                                  lessonsAutoplayAudio: lessonsAutoplayAudio,
                                                                  lessonsBatchSize: lessonsBatchSize,
                                                                  lessonsPresentationOrder: lessonsPresentationOrder.rawValue,
                                                                  reviewsAutoplayAudio: reviewsAutoplayAudio,
                                                                  reviewsDisplaySRSIndicator: reviewsDisplaySRSIndicator)
                        }
                    }
                }
            }
            .disabled(services.user == nil)
        }
        .navigationTitle("Profile")
        .onAppear(perform: populateDefaultState)
        .handlingErrors(in: viewModel.error)
        .task {
            await viewModel.fetchVoiceActors(services: services)
        }
    }

    private func populateDefaultState() {
        guard let user = services.user else {
            return
        }

        defaultVoiceActorID = user.preferences.defaultVoiceActorID
        lessonsAutoplayAudio = user.preferences.autoplayLessonsAudio
        lessonsBatchSize = user.preferences.lessonsBatchSize
        lessonsPresentationOrder = user.preferences.lessonsPresentationOrder
        reviewsAutoplayAudio = user.preferences.autoplayReviewsAudio
        reviewsDisplaySRSIndicator = user.preferences.displayReviewsSRSIndicator
    }

    @MainActor
    class ViewModel: ObservableObject {
        @Published var error: Error?
        @Published var voiceActors: [VoiceActor] = []

        func fetchVoiceActors(services: Services) async {
            do {
                let response = try await services.client.send(.voiceActors())
                voiceActors = Array(response.data)
            } catch {
                self.error = error
            }
        }

        func updateUserPreferences(
            services: Services,
            defaultVoiceActorID: Int? = nil,
            lessonsAutoplayAudio: Bool? = nil,
            lessonsBatchSize: Int? = nil,
            lessonsPresentationOrder: String? = nil,
            reviewsAutoplayAudio: Bool? = nil,
            reviewsDisplaySRSIndicator: Bool? = nil
        ) async {
            do {
                let response = try await services.client.send(
                    .updateUser(defaultVoiceActorID: defaultVoiceActorID,
                                lessonsAutoplayAudio: lessonsAutoplayAudio,
                                lessonsBatchSize: lessonsBatchSize,
                                lessonsPresentationOrder: lessonsPresentationOrder,
                                reviewsAutoplayAudio: reviewsAutoplayAudio,
                                reviewsDisplaySRSIndicator: reviewsDisplaySRSIndicator)
                )
                services.user = response.data
            } catch {
                self.error = error
            }
        }
    }
}
