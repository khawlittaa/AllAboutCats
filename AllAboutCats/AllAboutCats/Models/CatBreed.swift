//  CatBreed.swift

import Foundation

struct CatBreed: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let origin: String?
    let description: String?
    let temperament: String
    let lifeSpan: String?
    let weight: Weight
    let referenceImageId: String?
    let image: CatImage?

    enum CodingKeys: String, CodingKey {
        case id, name, origin, description, temperament, weight, image
        case lifeSpan         = "life_span"
        case referenceImageId = "reference_image_id"
    }

    var resolvedImageURL: URL? {
        if let url = image?.url       { return URL(string: url) }
        if let ref = referenceImageId { return URL(string: "https://cdn2.thecatapi.com/images/\(ref).jpg") }
        return nil
    }
}
