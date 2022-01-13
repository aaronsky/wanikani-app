import SwiftUI

extension Binding where Value == Bool {
    var negated: Self {
        .init(
            get: { !wrappedValue },
            set: { wrappedValue = !$0 }
        )
    }
}

extension View {
    public func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
