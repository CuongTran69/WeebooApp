import Foundation
import Alamofire
import PromiseKit

class AnimeService {
    func fetchImageAnime(tag: String) -> Promise<[AnimeModel]> {
        return Promise { seal in
            let url = "https://nekos.best/api/v2/\(tag)"
            AF.request(url).responseDecodable(of: AnimeResponse.self) { response in
                switch response.result {
                case .success(let response):
                    seal.fulfill(response.results)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}


