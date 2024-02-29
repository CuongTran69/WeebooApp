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

class AnimeViewModel: ObservableObject {
    let animeService    = AnimeService()
    let disposeBag      = DisposeBag()
    var tagActive       = TagAnimeImage.husbando.rawValue
    
    @Published var isLoading            = false
    @Published var animeModel           : AnimeModel?
    @Published var isGifActive          = false
    @Published var listTagActive        = [String]()
    @Published var showAlert            : (Bool, String) = (false, "")
    
    @Published var shareSheetPresent    = false
    @Published var isShowAppSettings    = false
    
    func fetchAnimeImage() {
        isLoading = true
        firstly {
            animeService.fetchImageAnime(tag: tagActive)
        }
        .ensure { [weak self] in
            self?.isLoading = false
        }
        .done { [weak self] animeModels in
            guard 
                let self = self,
                let anime = animeModels.first
            else { return }
            self.animeModel = anime
            self.setActiveTag(isGif: anime.isGif())
        }
        .catch { [weak self] error in
            guard let self = self else { return }
            self.showAlert = (false, error.localizedDescription)
        }
    }
    
    func setActiveTag(isGif: Bool, isFirstLoad: Bool = false) {
        /*
         isGif          : check tag đó có phải từ tag Gif
         isFirstLoad    : check chuyển từ Gif <-> Image thì reload lại ảnh
         */
        if isFirstLoad {
            if isGif {
                tagActive = TagAnimeGif.allCases.first?.rawValue ?? ""
            } else {
                tagActive = TagAnimeImage.allCases.first?.rawValue ?? ""
            }
            fetchAnimeImage()
        }
        isGifActive = isGif
        listTagActive = isGif ? TagAnimeGif.allCases.compactMap { $0.rawValue } : TagAnimeImage.allCases.compactMap { $0.rawValue }
    }
    
    func onTapTag(tag: String) {
        tagActive = tag
        fetchAnimeImage()
    }
    
    func downloadAndSaveImage() {
        guard let animeModel = animeModel,
              !animeModel.url.isEmpty,
              let url = URL(string: animeModel.url)
        else { return }
        
        
        isLoading = true
        AF.download(url).responseData { [weak self] response in
            guard let self = self,
                  let data = response.value,
                  let image = UIImage(data: data)
            else {
                self?.isLoading = false
                return
            }
            self.isLoading = false
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .authorized:
                    if animeModel.isGif() {
                        self.saveGifToLibrary(data: data)
                    } else {
                        self.saveImageToLibrary(image: image)
                    }
                case .restricted, .denied:
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.isShowAppSettings = true
                    }
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { newStatus in
                        if newStatus == .authorized {
                            if animeModel.isGif() {
                                self.saveGifToLibrary(data: data)
                            } else {
                                self.saveImageToLibrary(image: image)
                            }
                        }
                    }
                case .limited:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}

//MARK: - Other
extension AnimeViewModel {
    enum TagAnimeGif: String, CaseIterable {
        case baka, bite, blush, bored, cry, cuddle, dance, facepalm, feed, handhold, handshake, happy, highfive, hug, kick,kiss, laugh, lurk, nod, nom, nope, pat, peck, poke, pout, punch, shoot, shrug, slap, sleep, smile, smug, stare, think, thumbsup, tickle, wave, wink, yawn, yeet
    }
    
    enum TagAnimeImage: String, CaseIterable {
        case husbando, kitsune, neko, waifu
    }
    
    func saveGifToLibrary(data: Data) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }) { [weak self] (success, error) in
            guard let self = self else { return }
            if success {
                self.showAlert = (true, CustomError.saveImageSuccess.rawValue)
            } else if let _ = error {
                self.showAlert = (false, CustomError.saveImageError.rawValue)
            }
        }
    }
    
    func saveImageToLibrary(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] (success, error) in
            guard let self = self else { return }
            if success {
                self.showAlert = (true, CustomError.saveImageSuccess.rawValue)
            } else if let _ = error {
                self.showAlert = (false, CustomError.saveImageError.rawValue)
            }
        }
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

