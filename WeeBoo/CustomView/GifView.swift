//
//  GifView.swift
//  WeeBoo
//
//  Created by Cường Trần on 26/02/2024.
//

import Foundation
import SwiftUI
import UIKit
import ImageIO

struct GIFView: UIViewRepresentable {
    var gifURL: URL
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        loadGIF(imageView: imageView, url: gifURL)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Reload the GIF when the URL changes
        loadGIF(imageView: uiView, url: gifURL)
    }
    
    // Dedicated method to load and set the GIF
    private func loadGIF(imageView: UIImageView, url: URL) {
        DispatchQueue.global().async {
            guard let gifData = try? Data(contentsOf: url),
                  let gifImage = UIImage.gif(data: gifData) else {
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = gifImage
            }
        }
    }
}

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        
        if count > 1 {
            var images = [UIImage]()
            var duration = 0.0
            
            for i in 0..<count {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: image))
                    let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
                    duration += delaySeconds
                }
            }
            
            return UIImage.animatedImage(with: images, duration: duration)
        } else {
            return UIImage(data: data)
        }
    }
    
    static func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> Double {
        let delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == true,
           let gifProperties = gifPropertiesPointer.pointee {
            let gifProperties = unsafeBitCast(gifProperties, to: CFDictionary.self)
            
            var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
            if delayObject.doubleValue == 0 {
                delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
            }
            
            if let delay = delayObject as? Double, delay > 0 {
                return delay
            }
        }
        
        return delay
    }
}
