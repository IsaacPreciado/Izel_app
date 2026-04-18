import SwiftUI

struct StepperField: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...20

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(label.uppercased())
                    .font(Theme.Typography.label(11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.secondary)

                HStack {
                    Button { if value > range.lowerBound { value -= 1 } } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.Colors.secondary)
                    }
                    Spacer()
                    Text("\(value)")
                        .font(Theme.Typography.headline(18, weight: .bold))
                        .foregroundStyle(Theme.Colors.onSurface)
                    Spacer()
                    Button { if value < range.upperBound { value += 1 } } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.Colors.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(0) { StepperField(label: "Embarazos", value: $0) }
        .padding()
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content
    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }
    var body: some View { content($value) }
}
