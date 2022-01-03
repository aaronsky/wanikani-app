import SwiftUI

extension Binding where Value == Bool {
    var negated: Self {
        Self(get: { !wrappedValue },
             set: { wrappedValue = !$0 })
    }
}
