//
//  AnimeViewModel.swift
//  WeeBoo
//
//  Created by Cường Trần on 24/02/2024.
//

import Foundation
import PromiseKit
import Alamofire
import Photos
import RxSwift
import RxCocoa
import Then

class AnimeViewModel: ObservableObject, BaseMVVMViewModel {
    private let animeService            = AnimeService()
    let disposeBag                      = DisposeBag()
    @Published var isShowAppSettings    = false
    @Published var isGif                = false
    var currentTagAnimeImage            = TagAnimeImage.neko.rawValue
    var currentTagAnimeGif              = TagAnimeGif.bite.rawValue
    
    var state       = BehaviorRelay<State>(value: .init())
    var action      = PublishRelay<Action>()
    var mutation    = PublishRelay<Mutation>()
    var navigator   = PublishRelay<Navigation>()
    
    init() {
        setupFlow(disposeBag: disposeBag)
    }
}

extension AnimeViewModel {
    func mutate(action: Action, with state: State) {
        switch action {
        case .fetchAnimeImage:
            mutation.accept(.showLoading(isLoading: true))
            firstly { 
                animeService.fetchImageAnime(tag: currentTagAnimeGif)
            }
            .ensure { [weak self] in
                self?.mutation.accept(.showLoading(isLoading: false))
            }
            .done { [weak self] animes in
                guard let self = self,
                      let anime = animes.first,
                      !anime.url.isEmpty else { return }
                self.mutation.accept(.setMovieNameGif(string: anime.animeName))
                self.mutation.accept(.setImageUrlString(string: anime.url, isGif: anime.isGif()))
            }
            .catch { [weak self] error in
                self?.navigator.accept(.showAlert(isSuccess: false, message: error.localizedDescription))
            }
            
        case .downloadAndSaveImage:
            guard !state.urlString.isEmpty,
                  let url = URL(string: state.urlString) else { return }
            
            AF.download(url).responseData { [weak self] response in
                guard let self = self,
                      let data = response.value,
                      let image = UIImage(data: data) else { return }
                if self.isGif {
                    self.action.accept(.saveGifToLibrary(gif: data))
                } else {
                    self.action.accept(.saveImageToLibrary(image: image))
                }
            }
            
        case let .saveImageToLibrary(image):
            mutation.accept(.showLoading(isLoading: true))
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                self.mutation.accept(.showLoading(isLoading: false))
                switch status {
                case .authorized:
                    self.saveImage(image: image)
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { newStatus in
                        if newStatus == .authorized {
                            self.saveImage(image: image)
                        }
                    }
                case .restricted, .denied:
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.isShowAppSettings = true
                    }
                case .limited:
                   break
                @unknown default:
                    break
                }
            }
            
        case let .saveGifToLibrary(gif):
            mutation.accept(.showLoading(isLoading: true))
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                self.mutation.accept(.showLoading(isLoading: false))
                switch status {
                case .authorized:
                    self.saveGif(data: gif)
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { newStatus in
                        if newStatus == .authorized {
                            self.saveGif(data: gif)
                        }
                    }
                case .restricted, .denied:
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.isShowAppSettings = true
                    }
                case .limited:
                   break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func reduce(previousState: State, mutation: Mutation) -> State? {
        switch mutation {
        case let .setImageUrlString(string, isGif):
            return previousState.with {
                $0.urlString    = string
                self.isGif      = isGif
            }
            
        case let .setMovieNameGif(string):
            return previousState.with {
                $0.movieName = string
            }
            
        case let .showLoading(isLoading):
            return previousState.with {
                $0.isLoading = isLoading
            }
        }
    }
}

//MARK: - Other
extension AnimeViewModel {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func saveGif(data: Data) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }) { [weak self] success, error in
            guard let self = self else { return }
            self.mutation.accept(.showLoading(isLoading: false))
            if let _ = error {
                self.navigator.accept(.showAlert(isSuccess: false, message: CustomError.saveImageError.rawValue))
            } else if success {
                self.navigator.accept(.showAlert(isSuccess: true, message: CustomError.saveImageSuccess.rawValue))
            }
        }
    }
    
    func saveImage(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            guard let self = self else { return }
            self.mutation.accept(.showLoading(isLoading: false))
            if let _ = error {
                self.navigator.accept(.showAlert(isSuccess: false, message: CustomError.saveImageError.rawValue))
            } else if success {
                self.navigator.accept(.showAlert(isSuccess: true, message: CustomError.saveImageSuccess.rawValue))
            }
        }
    }
}

extension AnimeViewModel {
    struct State: Then {
        var isLoading   = false
        var urlString   = ""
        var movieName   = ""
    }
    
    enum Action {
        case fetchAnimeImage
        case downloadAndSaveImage
        case saveImageToLibrary(image: UIImage)
        case saveGifToLibrary(gif: Data)
    }
    
    enum Mutation {
        case setImageUrlString(string: String, isGif: Bool)
        case setMovieNameGif(string: String)
        case showLoading(isLoading: Bool)
    }
    
    enum Navigation {
        case showAlert(isSuccess: Bool, message: String)
    }
    
    enum TagAnimeGif: String, CaseIterable {
        case baka, bite, blush, bored, cry, cuddle, dance, facepalm, feed, handhold, handshake, happy, highfive, hug, kick,kiss, laugh, lurk, nod, nom, nope, pat, peck, poke, pout, punch, shoot, shrug, slap, sleep, smile, smug, stare, think, thumbsup, tickle, wave, wink, yawn, yeet
    }
    
    enum TagAnimeImage: String, CaseIterable {
        case husbando, kitsune, neko, waifu
    }
}
