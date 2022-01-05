import SwiftUI

extension Binding where Value == Bool {
    var negated: Self {
        .init(
            get: { !wrappedValue },
            set: { wrappedValue = !$0 }
        )
    }
}
