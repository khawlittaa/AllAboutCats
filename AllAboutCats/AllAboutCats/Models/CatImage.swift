//  CatImage.swift

import Foundation

struct CatImage: Decodable, Hashable {
    let id: String
    let url: String
    let width: Int?
    let height: Int?
}
