//  CatAsyncImageView.swift

import SwiftUI
import SwiftUI

struct CatAsyncImageView: View {
    let url: URL?
    var aspectRatio: CGFloat = 4 / 3
    var cornerRadius: CGFloat = 12

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ShimmerView()

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeIn(duration: 0.25)))

            case .failure:
                ZStack {
                    Color(.secondarySystemBackground)
                    VStack(spacing: 6) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color(.systemGray3))
                        Text("No image")
                            .font(.caption)
                            .foregroundStyle(Color(.systemGray3))
                    }
                }

            @unknown default:
                ShimmerView()
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

#Preview { CatAsyncImageView(url: nil).padding() }
