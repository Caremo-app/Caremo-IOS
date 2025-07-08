import SwiftUI

struct CaremoTheme {
    
    // MARK: - Color Palette
    
    static let primaryRed = Color(hex: "#E03F3E")
    static let darkTeal = Color(hex: "#058789")
    static let white = Color.white
    static let lightGrayBG = Color(UIColor.systemGray6)
    
    // MARK: - Typography Scale
    
    struct Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let subtitle = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
    }
    
    // MARK: - Button Style
    
    struct ButtonStyle: SwiftUI.ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(CaremoTheme.primaryRed)
                .foregroundColor(.white)
                .cornerRadius(12)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    // MARK: - Corner Radius Standard
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }
    
    // MARK: - Glassmorphism Border Gradient
    
    static let glassBorderGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "#E03F3E").opacity(0.5), // Caremo Red
            Color(hex: "#058789").opacity(0.3)  // Caremo Teal
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension to support hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
