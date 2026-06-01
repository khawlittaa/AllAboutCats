//  CatInfoView.swift

import SwiftUI

struct CatInfoView: View {

    @ObservedObject var viewModel: CatInfoViewModel

    var body: some View {
        ScrollView {
            AsyncImage(url: viewModel.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .contentShape(Rectangle())

                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(ProgressView())

                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color(.systemGray3))
                        )
                }
            }

            VStack(alignment: .leading, spacing: 20) {
                nameHeader
                statsRow
                Divider()
                descriptionSection
                Divider()
                temperamentSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var nameHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.name)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)

            Label(viewModel.origin, systemImage: "mappin.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatBadge(
                icon: "scalemass.fill",
                title: viewModel.weight,
                label: "Weight"
            )
            StatBadge(
                icon: "heart.fill",
                title: viewModel.lifeSpan,
                label: "Life Span"
            )
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            Text(viewModel.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
    }

    private var temperamentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Temperament")
                .font(.headline)

            if viewModel.temperament.isEmpty {
                Text("Not available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 80), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(viewModel.temperament, id: \.self) { trait in
                        Text(trait)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accentColor.opacity(0.12))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        CatInfoView(
            viewModel: CatInfoViewModel(
                breed: CatBreed(
                    id: "bur",
                    name: "Burmese",
                    origin: "Burma",
                    description: "The Burmese are a sociable and people-oriented breed. They love to follow their humans from room to room, sleep in bed with them, and generally be involved in everything they do.",
                    temperament: "Curious, Playful, Energetic, Affectionate, Social",
                    lifeSpan: "10 - 16",
                    weight: Weight(imperial: nil, metric: "3 - 5"),
                    referenceImageId: "4lXnnfxac",
                    image: nil
                )
            )
        )
    }
}
