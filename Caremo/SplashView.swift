import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            Image("health_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("caremo_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotation))
                    .shadow(radius: 10)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotation = 360
                        }
                    }

                Text("Caremo")
                    .font(CaremoTheme.Typography.title)
                    .foregroundColor(.white)
            }
            .opacity(isActive ? 0 : 1)
            .scaleEffect(isActive ? 0.9 : 1)
            .animation(.easeOut(duration: 1.0), value: isActive)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
