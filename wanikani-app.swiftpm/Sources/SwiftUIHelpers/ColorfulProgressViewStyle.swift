import SwiftUI

public struct ColorfulProgressViewStyle: ProgressViewStyle {
    public var accentColor: Color
    public var primaryColor: Color

    public init(
        accentColor: Color = Color.accentColor,
        primaryColor: Color = Color(.systemGray4)
    ) {
        self.accentColor = accentColor
        self.primaryColor = primaryColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(primaryColor)

                RoundedRectangle(cornerRadius: 12)
                    .frame(width: (configuration.fractionCompleted ?? 0) * proxy.size.width)
                    .foregroundColor(accentColor)

                HStack {
                    Spacer()
                    configuration.label
                        .padding(.trailing, 8)
                }
            }
        }
    }
}
