import SwiftUI

struct IconBadge: View {
    let systemName: String
    var background: Color = Theme.Colors.symptomChipBg
    var foreground: Color = Theme.Colors.primary
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.35, style: .continuous))
    }
}

#Preview {
    IconBadge(systemName: "drop.fill").padding()
}
