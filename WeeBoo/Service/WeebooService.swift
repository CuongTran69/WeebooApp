import Foundation
import Alamofire
import PromiseKit

class AnimeService {
    func fetchImageAnime() -> Promise<[AnimeImage]> {
        return Promise { seal in
            let url = "https://nekos.best/api/v2/waifu"
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


