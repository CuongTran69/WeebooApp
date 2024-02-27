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
    
    
    // State loading
    @State private var isLoading = false
    
    // State alert view
    @State private var showAlert        = false
    @State private var messageAlert     = ""
    @State private var isAlertSuccess   = false
    
    var body: some View {
        let state = viewModel.state.value
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                if let animeModel = state.animeModel {
                    if viewModel.isGif,
                       let gifUrl = URL(string: animeModel.url) {
                        GIFView(gifURL: gifUrl)
                            .padding(.horizontal)
                            .scaledToFit()
                            .frame(minWidth: 200, maxWidth: 400)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        
                        HStack {
                            Text("Movie Name:")
                            Text("\(animeModel.animeName ?? "")")
                                .bold()
                        }
                        .padding()
                    } else {
                        AsyncImage(url: URL(string: animeModel.url)) { phase in
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
                        
                        HStack {
                            Text("Artist Name:")
                            Text("\(animeModel.artistName ?? "")")
                                .bold()
                        }
                        .padding()
                    }   
                }
                
                Spacer()
                
                TagView(viewModel: viewModel)
                
                ButtonView(viewModel: viewModel, itemsToShare: [state.animeModel?.url ?? ""])
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
            viewModel.action.accept(.fetchAnimeImage(tag: state.currentTag))
            bindViewModel()
        }
        .alert(isPresented: $viewModel.isShowAppSettings) { 
            Alert(title: Text("Permission Denied"),
                  message: Text("Please enable access to your photos in the Settings app."),
                  primaryButton: .default(Text("Open settings"), action: { 
                viewModel.openAppSettings()
            }),
                  secondaryButton: .cancel())
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

//MARK: - Bottom Button View
struct ButtonView: View {
    var viewModel: AnimeViewModel
    // State share
    @State private var shareSheetPresent    = false
    var itemsToShare                        : [Any]
    
    var body: some View {
        HStack {
            Button("Other") {
                viewModel.action.accept(.fetchAnimeImage(tag: viewModel.state.value.currentTag))
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
        .sheet(isPresented: $shareSheetPresent) { 
            ShareSheet(items: itemsToShare)
        }
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

class TimerManager: ObservableObject {
    @Published var timerFinished = false
    private var timer: AnyCancellable?
    
    func startTimer() {
        timerFinished = false
        var timeRemaining = 2
        
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
