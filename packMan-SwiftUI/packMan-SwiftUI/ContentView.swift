import SwiftUI

// Custom Shape for Pac-Man
struct PacManShape: Shape {
    var openAmount: Double

    var animatableData: Double {
        get { openAmount }
        set { openAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle(degrees: openAmount)
        let endAngle = Angle(degrees: 360 - openAmount)

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}

// Main View for Pac-Man Animation
struct PacManAnimationView: View {
    @State private var openAmount = 45.0
    @State private var moveOffset: CGFloat = -200
    @State private var eatenLetters = 0

    private let letters = ["P", "A", "C", "-", "M", "A", "N"]
    private let letterWidth: CGFloat = 50
    private let spacing: CGFloat = 20
    private let animationDuration: Double = 26.0 // Duration for Pac-Man's movement

    var body: some View {
        GeometryReader { geometry in
            let totalTextWidth = calculateTextWidth()
            let totalDistance = geometry.size.width + 100 // Total distance for Pac-Man to move across the screen

            ZStack {
                // Display the letters for "PAC-MAN"
                HStack(spacing: spacing) {
                    ForEach(0..<letters.count, id: \.self) { index in
                        Text(letters[index])
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(eatenLetters > index ? 0 : 1) // Disappear once "eaten"
                    }
                }
                .frame(width: totalTextWidth)
                .offset(x: (geometry.size.width - totalTextWidth) / 2, y: geometry.size.height / 2 - 50) // Center horizontally and adjust vertically

                // Pac-Man
                PacManShape(openAmount: openAmount)
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                    .offset(x: moveOffset, y: geometry.size.height / 2 - 50)
                    .onAppear {
                        animatePacMan()
                        synchronizeLetterEating(with: totalTextWidth)
                    }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    private func calculateTextWidth() -> CGFloat {
        CGFloat(letters.count) * letterWidth + CGFloat(letters.count - 1) * spacing
    }

    private func animatePacMan() {
        withAnimation(
            Animation.easeInOut(duration: 0.3)
                .repeatForever(autoreverses: true)
        ) {
            openAmount = 5
        }

        withAnimation(
            Animation.linear(duration: animationDuration)
                .repeatForever(autoreverses: false)
        ) {
            moveOffset = UIScreen.main.bounds.width + 100 // Move Pac-Man off-screen
        }
    }

    private func synchronizeLetterEating(with textWidth: CGFloat) {
        let distancePerLetter = textWidth / CGFloat(letters.count)
        let totalDistance = textWidth + UIScreen.main.bounds.width
        let interval = animationDuration * (distancePerLetter / totalDistance)

        for index in 0..<letters.count {
            let delay = interval * Double(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    eatenLetters += 1
                }
            }
        }
    }
}

#Preview {
    PacManAnimationView()
}
