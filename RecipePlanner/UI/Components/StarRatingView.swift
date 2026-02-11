import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    let starSize: CGFloat
    let color: Color
    
    init(rating: Double, starSize: CGFloat = 16, color: Color = .orange) {
        self.rating = rating
        self.starSize = starSize
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .foregroundColor(color)
                    .font(.system(size: starSize))
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        let fillAmount = rating - Double(index - 1)
        
        if fillAmount >= 1.0 {
            return "star.fill"
        } else if fillAmount >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// Interactive version for user input
struct InteractiveStarRatingView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    let starSize: CGFloat
    
    init(rating: Binding<Int>, starSize: CGFloat = 30) {
        self._rating = rating
        self.starSize = starSize
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(.orange)
                        .font(.system(size: starSize))
                }
            }
        }
    }
}
