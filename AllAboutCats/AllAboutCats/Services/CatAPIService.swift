//  CatAPIService.swift

import Foundation

protocol CatAPIServiceProtocol: Sendable {
    func fetchBreeds(page: Int, limit: Int) async throws -> [CatBreed]
}

enum CatAPIError: LocalizedError {
    case invalidURL
    case badResponse(Int)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Invalid URL."
        case .badResponse(let c):  return "Server error: \(c)."
        case .missingAPIKey:       return "API key missing. Add CAT_API_KEY to Info.plist."
        }
    }
}

final class CatAPIService: CatAPIServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = dec
    }

    func fetchBreeds(page: Int = 1, limit: Int = 12) async throws -> [CatBreed] {
        let key = try apiKey()
        guard let url = URL(string: "https://api.thecatapi.com/v1/breeds?page=\(page)&limit=\(limit)") else {
            throw CatAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(key, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw CatAPIError.badResponse(code)
        }

        return try decoder.decode([CatBreed].self, from: data)
    }

    /// Reads the key from Info.plist (injected via xcconfig — never hard-code).
    private func apiKey() throws -> String {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "CAT_API_KEY") as? String,
            !key.isEmpty
        else { throw CatAPIError.missingAPIKey }
        return key
    }
}
