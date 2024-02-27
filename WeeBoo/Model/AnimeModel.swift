//
//  AnimeModel.swift
//  WeeBoo
//
//  Created by Cường Trần on 24/02/2024.
//

import Foundation

struct AnimeModel: Codable {
    let url         : String
    let animeName   : String?
    let artistName  : String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case animeName      = "anime_name"
        case artistName     = "artist_name"
    }
    
    func isGif() -> Bool {
        url.contains(".gif")
    }
}

struct AnimeResponse: Codable {
    let results: [AnimeModel]
}
