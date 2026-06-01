//  CatsListViewModel.swift

import Foundation
import Combine

@MainActor
final class CatsListViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var breeds: [CatBreed] = []
    @Published private(set) var state: State = .idle

    private let service: CatAPIServiceProtocol

    init(service: CatAPIServiceProtocol = CatAPIService()) {
        self.service = service
    }

    func load() async {
        guard state == .idle else { return }
        state = .loading
        do {
            breeds = try await service.fetchBreeds(page: 1, limit: 12)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func retry() async {
        state = .idle
        await load()
    }
}
