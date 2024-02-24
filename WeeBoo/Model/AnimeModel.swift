//
//  AnimeModel.swift
//  WeeBoo
//
//  Created by Cường Trần on 24/02/2024.
//

import Foundation

struct AnimeImage: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct AnimeResponse: Codable {
    let results: [AnimeImage]
}
