import SwiftUI

enum Theme {

    enum Colors {
        static let primary              = Color(hex: 0xAC0051)
        static let primaryContainer     = Color(hex: 0xD90368)
        static let onPrimary            = Color.white
        static let onPrimaryContainer   = Color(hex: 0xFFEFF1)
        static let primaryFixed         = Color(hex: 0xFFD9E0)
        static let primaryFixedDim      = Color(hex: 0xFFB1C3)

        static let secondary            = Color(hex: 0x4C616C)
        static let secondaryContainer   = Color(hex: 0xCFE6F3)
        static let onSecondary          = Color.white
        static let onSecondaryContainer = Color(hex: 0x526772)

        static let tertiary             = Color(hex: 0x125F67)
        static let tertiaryContainer    = Color(hex: 0x347880)
        static let tertiaryFixed        = Color(hex: 0xABEEF7)
        static let tertiaryFixedDim     = Color(hex: 0x8FD1DA)
        static let onTertiary           = Color.white
        static let onTertiaryContainer  = Color(hex: 0xD4FAFF)
        static let onTertiaryFixed      = Color(hex: 0x001F23)
        static let onTertiaryFixedVariant = Color(hex: 0x004F56)

        static let surface              = Color(hex: 0xF4FAFF)
        static let surfaceBright        = Color(hex: 0xF4FAFF)
        static let surfaceDim           = Color(hex: 0xC7DDEA)
        static let surfaceContainerLowest = Color.white
        static let surfaceContainerLow    = Color(hex: 0xE7F6FF)
        static let surfaceContainer       = Color(hex: 0xDBF1FE)
        static let surfaceContainerHigh   = Color(hex: 0xD5ECF9)
        static let surfaceContainerHighest = Color(hex: 0xCFE6F3)

        static let background           = Color(hex: 0xF4FAFF)
        static let onBackground         = Color(hex: 0x071E27)
        static let onSurface            = Color(hex: 0x071E27)
        static let onSurfaceVariant     = Color(hex: 0x5B3F45)

        static let outline              = Color(hex: 0x8F6F75)
        static let outlineVariant       = Color(hex: 0xE3BDC4)

        static let error                = Color(hex: 0xBA1A1A)
        static let errorContainer       = Color(hex: 0xFFDAD6)
        static let onError              = Color.white
        static let onErrorContainer     = Color(hex: 0x93000A)

        static let symptomChipBg        = Color(hex: 0xFFC1DA)
    }

    enum Typography {
        static let headline     = "Manrope"
        static let body         = "Inter"
        static let label        = "Inter"

        static func headline(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .custom(headline, size: size).weight(weight)
        }

        static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom(body, size: size).weight(weight)
        }

        static func label(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
            .custom(label, size: size).weight(weight)
        }
    }

    enum Radius {
        static let sm: CGFloat      = 4
        static let md: CGFloat      = 8
        static let lg: CGFloat      = 16
        static let xl: CGFloat      = 24
        static let xxl: CGFloat     = 32
        static let pill: CGFloat    = 9999
    }

    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    enum Shadow {
        static let card = ShadowStyle(
            color: Color(hex: 0x071E27).opacity(0.06),
            radius: 12, x: 0, y: 8
        )
        static let primaryCTA = ShadowStyle(
            color: Color(hex: 0xD90368).opacity(0.25),
            radius: 16, x: 0, y: 12
        )
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension View {
    func themeShadow(_ style: Theme.ShadowStyle = Theme.Shadow.card) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
