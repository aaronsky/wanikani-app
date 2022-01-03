import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var services: Services
    
    @State private var token: String = ""
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        VStack {
            Text("Requires a WaniKani access token")
            SecureField("Access token", text: $token)
                .padding()
                .background(Color(.sRGB, white: 0.9, opacity: 1))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            Button(action: {
                isLoading = true

                Task {
                    do {
                        try await services.login(token)
                        dismiss()
                    } catch {
                        self.error = error
                        isLoading = false
                    }
                }
            }, label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Log In")
                }
            }).disabled(token.isEmpty || isLoading)
        }
        .handlingErrors(in: error)
        .padding()
    }
}
