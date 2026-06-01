//  SkeletonCard.swift

import SwiftUI

struct SkeletonCard: View {
    let width: CGFloat
    @State private var phase: CGFloat = -1

    private var imageHeight: CGFloat { width * 0.85 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(shimmer)
                .frame(width: width, height: imageHeight)

            VStack(alignment: .leading, spacing: 6) {
                Capsule()
                    .fill(shimmer)
                    .frame(width: width * 0.7, height: 12)
                Capsule()
                    .fill(shimmer)
                    .frame(width: width * 0.45, height: 10)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .frame(width: width)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onAppear {
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                phase = 1.3
            }
        }
    }

    private var shimmer: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(.systemGray5), location: phase - 0.3),
                .init(color: Color(.systemGray4), location: phase),
                .init(color: Color(.systemGray5), location: phase + 0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
