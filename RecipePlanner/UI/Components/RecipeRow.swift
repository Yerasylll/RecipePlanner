import SwiftUI
import Kingfisher

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageURL = recipe.image {
                KFImage(URL(string: imageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let time = recipe.readyInMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(time) min")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                if recipe.isFavorite {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text("Favorite")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

