import SwiftUI

struct GlassmorphismView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background blur glassmorphism
            BlurView(style: .systemUltraThinMaterialDark)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    CaremoTheme.primaryRed.opacity(0.5),
                                    CaremoTheme.darkTeal.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)

            // Content inside glass card
            content
                .padding()
        }
        .padding(.horizontal)
    }
}
