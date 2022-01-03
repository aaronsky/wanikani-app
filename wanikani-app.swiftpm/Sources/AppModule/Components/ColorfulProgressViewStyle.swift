import SwiftUI

struct ColorfulProgressViewStyle: ProgressViewStyle {
    var accentColor: Color = Color.accentColor
    var primaryColor: Color = Color(.systemGray4)

    func makeBody(configuration: Configuration) -> some View {
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
