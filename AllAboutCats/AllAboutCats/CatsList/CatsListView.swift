//  CatsListView.swift

import SwiftUI

struct CatsListView: View {

    @StateObject private var viewModel = CatsListViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Cat Breeds")
                .navigationBarTitleDisplayMode(.large)
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingGrid
        case .loaded:
            breedsGrid
        case .error(let message):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message).multilineTextAlignment(.center)
            } actions: {
                Button("Try Again") { Task { await viewModel.retry() } }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private var breedsGrid: some View {
        GeometryReader { screen in
            let spacing: CGFloat = 12
            let padding: CGFloat = 16
            let cardWidth = (screen.size.width - padding * 2 - spacing) / 2

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(cardWidth)),
                        GridItem(.fixed(cardWidth))
                    ],
                    spacing: spacing
                ) {
                    ForEach(viewModel.breeds) { breed in
                        NavigationLink(value: breed) {
                            BreedCard(breed: breed, width: cardWidth)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, padding)
                .padding(.vertical, 8)
            }
            .navigationDestination(for: CatBreed.self) { breed in
                CatInfoView(viewModel: CatInfoViewModel(breed: breed))
            }
        }
    }

    private var loadingGrid: some View {
        GeometryReader { screen in
            let spacing: CGFloat = 12
            let padding: CGFloat = 16
            let cardWidth = (screen.size.width - padding * 2 - spacing) / 2

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(cardWidth)),
                        GridItem(.fixed(cardWidth))
                    ],
                    spacing: spacing
                ) {
                    ForEach(0..<12, id: \.self) { _ in
                        SkeletonCard(width: cardWidth)
                    }
                }
                .padding(.horizontal, padding)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview { CatsListView() }
