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
    private let animeService        = AnimeService()
    let disposeBag                  = DisposeBag()
    @Published var imageURL         = String()
    
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
        case let .fetchAnimeImage(tag):
            mutation.accept(.showLoading(isLoading: true))
            firstly { 
                animeService.fetchImageAnime(tag: tag)
            }
            .ensure { [weak self] in
                self?.mutation.accept(.showLoading(isLoading: false))
            }
            .done { [weak self] images in
                guard let self = self,
                      let image = images.first,
                      !image.url.isEmpty else { return }
                self.mutation.accept(.setImageUrlString(string: image.url))
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
                self.action.accept(.saveToLibrary(image: image))
            }
            
        case let .saveToLibrary(image):
            mutation.accept(.showLoading(isLoading: true))
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    self.mutation.accept(.showLoading(isLoading: false))
                    return
                }
                
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
    }
    
    func reduce(previousState: State, mutation: Mutation) -> State? {
        switch mutation {
        case let .setImageUrlString(string):
            return previousState.with {
                $0.urlString = string
                self.imageURL = string
            }
            
        case let .showLoading(isLoading):
            return previousState.with {
                $0.isLoading = isLoading
            }
        }
    }
    
    struct State: Then {
        var isLoading = false
        var urlString = ""
    }
    
    enum Action {
        case fetchAnimeImage(tag: String)
        case downloadAndSaveImage
        case saveToLibrary(image: UIImage)
    }
    
    enum Mutation {
        case setImageUrlString(string: String)
        case showLoading(isLoading: Bool)
    }
    
    enum Navigation {
        case showAlert(isSuccess: Bool, message: String)
    }
}
