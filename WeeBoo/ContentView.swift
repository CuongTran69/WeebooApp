//
//  ContentView.swift
//  WeeBoo
//
//  Created by Cường Trần on 23/02/2024.
//

import SwiftUI
import RxSwift
import Combine
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel       = AnimeViewModel()
    @ObservedObject var timerManager    = TimerManager()
    
    // State share
    @State private var shareSheetPresent    = false
    @State private var itemsToShare         : [Any] = []
    
    // State loading
    @State private var isLoading = false
    
    // State alert view
    @State private var showAlert        = false
    @State private var messageAlert     = ""
    @State private var isAlertSuccess   = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
//                if let gifUrl = URL(string: viewModel.imageURL) {
//                    GIFView(gifURL: gifUrl)
//                }
                AsyncImage(url: URL(string: viewModel.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case let .success(image):
                        image
                            .resizable()
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        Image(systemName: "photo")
                    }
                }
                .scaledToFit()
                .frame(width: 300, height: 300)
                
                Spacer()
                
                HStack {
                    Button("Create other") {
                        viewModel.action.accept(.fetchAnimeImage(tag: "kiss"))
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Save") {
                        viewModel.action.accept(.downloadAndSaveImage)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Share") {
                        shareSheetPresent = true
                    }
                    .padding()
                    .background(.mint)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            if showAlert, !timerManager.timerFinished {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(0.3)
                    
                    CustomAlerView(isSuccess: isAlertSuccess, messageAlert: messageAlert)
                        .onAppear {
                            timerManager.startTimer()
                        }
                }
            }
            
            if isLoading {
                ZStack {
                    Color.black
                        .opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    CustomLoadingView()
                        .transition(.opacity)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.action.accept(.fetchAnimeImage(tag: "kiss"))
            bindViewModel()
        }
        .sheet(isPresented: $shareSheetPresent) { 
            ShareSheet(items: itemsToShare)
        }
    }
    
    func bindViewModel() {
        viewModel.navigator
            .subscribe(onNext: { [self] navigator in
                switch navigator {
                case let .showAlert(isSuccess, message):
                    self.showAlert = true
                    self.messageAlert = message
                    self.isAlertSuccess = isSuccess
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.state.compactMap { $0.isLoading }
            .subscribe(onNext: { [self] loading in
                self.isLoading = loading
            })
            .disposed(by: viewModel.disposeBag)
    }
}

struct CustomAlerView: View {
    var isSuccess: Bool
    var messageAlert: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isSuccess ? "checkmark.circle" : "xmark.circle")
                .font(.largeTitle)
                .foregroundColor(isSuccess ? .green : .red)
            Text(messageAlert)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class TimerManager: ObservableObject {
    @Published var timerFinished = false
    private var timer: AnyCancellable?

    func startTimer() {
        timerFinished = false
        var timeRemaining = 3

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    self.timerFinished = true
                    self.timer?.cancel()
                }
            }
    }
}

struct CustomLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .green, .yellow, .mint]), center: .center), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0))
            .animation(self.isAnimating ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
            .onAppear() {
                self.isAnimating = true
            }
            .onDisappear() {
                self.isAnimating = false
            }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct GIFView: UIViewRepresentable {
    var gifURL: URL
    
    func makeUIView(context: Context) -> UIImageView {
        // Initial empty UIImageView
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Adjust as needed
        
        // Asynchronously load the GIF data from the URL
        DispatchQueue.global().async {
            guard let gifData = try? Data(contentsOf: self.gifURL),
                  let gifImage = UIImage.gif(data: gifData) else {
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = gifImage
            }
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Update the view if needed
    }
}

// UIImage extension remains the same as in the previous example
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
        var delay = 0.1
        
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
