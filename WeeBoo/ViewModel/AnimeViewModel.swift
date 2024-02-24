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

class AnimeViewModel: ObservableObject {
    private let animeService = AnimeService()
    @Published var imageURL = String()
    
    func fetchImageAnime() {
        animeService.fetchImageAnime().done { images in
            if let url = images.first?.url {
                self.imageURL = url
            }
        }.catch { error in
            print(error)
        }
    }
    
    func downloadAndSaveImage() {
        guard !imageURL.isEmpty,
              let url = URL(string: imageURL) else { return }
        
        AF.download(url).responseData { [weak self] response in
            guard let self = self else { return }
            if let data = response.value, let image = UIImage(data: data) {
                self.saveImageToPhotoLibrary(image)
            }
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if let error = error {
                    print("Error saving image to photo library: \(error)")
                } else if success {
                    print("Image successfully saved to photo library.")
                }
            }
        }
    }
}
