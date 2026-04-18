import SwiftUI
import UIKit

struct LabeledField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(label.uppercased())
                    .font(Theme.Typography.label(11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.secondary)

                TextField(placeholder, text: $text)
                    .font(Theme.Typography.headline(18, weight: .semibold))
                    .foregroundStyle(Theme.Colors.onSurface)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper("") {
        LabeledField(label: "Peso (kg)", placeholder: "00.0", text: $0, keyboard: .decimalPad)
    }
    .padding()
}
