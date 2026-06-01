//  CatInfoViewModel.swift
import Foundation
import Combine

@MainActor
final class CatInfoViewModel: ObservableObject {

    @Published var imageURL: URL?

    let name: String
    let origin: String
    let description: String
    let weight: String
    let lifeSpan: String
    let temperament: [String]

    private let breed: CatBreed
    private let service: CatAPIServiceProtocol

    init(breed: CatBreed, service: CatAPIServiceProtocol = CatAPIService()) {
        self.breed   = breed
        self.service = service

        self.name        = breed.name
        self.origin      = breed.origin ?? "Unknown"
        self.description = breed.description ?? "No description available."
        self.weight      = breed.weight.metric.isEmpty ? "Unknown" : "\(breed.weight.metric) kg"
        self.lifeSpan    = {
            guard let ls = breed.lifeSpan, !ls.isEmpty else { return "Unknown" }
            return "\(ls) years"
        }()
        self.temperament = (breed.temperament ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        self.imageURL = breed.resolvedImageURL
    }
}
